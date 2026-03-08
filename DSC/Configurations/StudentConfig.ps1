Configuration StudentBaseline {

    param(
        [PSCredential]$DomainAdminCredential,
        [PSCredential]$DsrmCredential,
        [PSCredential]$UserCredential
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDSC
    Import-DscResource -ModuleName ActiveDirectoryDSC
    Import-DscResource -ModuleName NetworkingDsc
    # Specify the versions or use '*' to force a deep search of the system modules
    Import-DscResource -ModuleName GroupPolicyDsc 
    Import-DscResource -ModuleName GPRegistryPolicyDsc 

    Node $AllNodes.NodeName {

        # ---------------- NETWORK ----------------
        IPAddress InternalStaticIP {
            InterfaceAlias = $Node.InterfaceAlias_Internal
            AddressFamily  = 'IPv4'
            IPAddress      = $Node.IPv4Address_Internal
        }

        DNSServerAddress InternalDNS {
            InterfaceAlias = $Node.InterfaceAlias_Internal
            AddressFamily  = 'IPv4'
            Address        = $Node.DnsServers_Internal
            DependsOn      = '[IPAddress]InternalStaticIP'
        }

        # ---------------- WINDOWS FEATURES ----------------
        WindowsFeature ADDS {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature RSATADDS {
            Name   = 'RSAT-AD-Tools'
            Ensure = 'Present'
        }

        WindowsFeature GPMC {
            Name   = 'GPMC'
            Ensure = 'Present'
        }

        # ---------------- DOMAIN CREATION ----------------
        ADDomain BarmBuzzDomain {
            DomainName                    = $Node.DomainName
            DomainNetbiosName             = $Node.DomainNetBIOSName
            DomainMode                    = $Node.DomainMode
            ForestMode                    = $Node.ForestMode
            Credential                    = $DomainAdminCredential
            SafeModeAdministratorPassword = $DsrmCredential
            DependsOn = @(
                '[WindowsFeature]ADDS',
                '[DNSServerAddress]InternalDNS'
            )
        }

        WaitForADDomain WaitForBarmBuzz {
            DomainName = $Node.DomainName
            Credential = $DomainAdminCredential
        }

        # ---------------- OU CREATION ----------------
        foreach ($OU in $Node.OrganizationalUnits) {
            $ouPath = if ($OU.ParentPath) { "$($OU.ParentPath),$($Node.DomainDN)" } else { $Node.DomainDN }
            $oudep = if ($OU.DependsOnKey) { "[ADOrganizationalUnit]OU_$($OU.DependsOnKey)" } else { "[WaitForADDomain]WaitForBarmBuzz" }

            ADOrganizationalUnit "OU_$($OU.Key)" {
                Name  = $OU.Name
                Path  = $ouPath
                Description = $OU.Description
                ProtectedFromAccidentalDeletion = $OU.Protected
                Ensure = 'Present'
                Credential = $DomainAdminCredential
                DependsOn  = $oudep
            }
        }

        # ---------------- GROUPS ----------------
        foreach ($grp in $Node.SecurityGroups) {
            $grpPath = "$($grp.OUPath),$($Node.DomainDN)"
            $grpDep = if ($grp.DependsOnOUKey) { "[ADOrganizationalUnit]OU_$($grp.DependsOnOUKey)" } else { "[WaitForADDomain]WaitForBarmBuzz" }

            ADGroup "Group_$($grp.Key)" {
                GroupName = $grp.GroupName
                GroupScope = $grp.GroupScope
                Category = $grp.Category
                Path = $grpPath
                Description = $grp.Description
                MembersToInclude = $grp.MemberToInclude
                Ensure = 'Present'
                Credential = $DomainAdminCredential
                DependsOn = $grpDep
            }
        }

        # ---------------- DELEGATION ----------------
        foreach ($deleg in $Node.Delegations) {
            $delegPath = "$($deleg.TargetOUPath),$($Node.DomainDN)"
            $delegIdentity = "$($Node.DomainNetBIOSName)\$($deleg.IdentityGroupName)"

            ADObjectPermissionEntry $deleg.Key {
                Path = $delegPath
                IdentityReference = $delegIdentity
                ActiveDirectoryRights = $deleg.Rights
                AccessControlType = $deleg.AccessControlType
                ObjectType = $deleg.ObjectTypeGuid
                ActiveDirectorySecurityInheritance = $deleg.InheritanceType
                InheritedObjectType = $deleg.InheritedObjectType
                Ensure = 'Present'
                DependsOn = @(
                    "[ADGroup]Group_$($deleg.DependsOnGroupKey)",
                    "[ADOrganizationalUnit]OU_$($deleg.DependsOnOUKey)"
                )
            }
        }

        # ---------------- USERS ----------------
        foreach ($user in $Node.ADUsers) {
            $userPath = "$($user.OUPath),$($Node.DomainDN)"
            ADUser "User_$($user.Key)" {
                DomainName = $Node.DomainName
                UserName = $user.UserName
                GivenName = $user.GivenName
                Surname = $user.Surname
                DisplayName = $user.DisplayName
                UserPrincipalName = $user.UserPrincipalName
                Path = $userPath
                JobTitle = $user.JobTitle
                Department = $user.Department
                Description = $user.Description
                Password = $UserCredential
                Enabled = $true
                Ensure = 'Present'
                ChangePasswordAtLogon = $user.ChangePasswordAtLogon
                Credential = $DomainAdminCredential
                DependsOn = "[ADOrganizationalUnit]OU_$($user.DependsOnOUKey)"
            }
        }

        # ---------------- PASSWORD POLICY ----------------
        ADDomainDefaultPasswordPolicy SetPasswordPolicy {
            DomainName = $Node.DomainName
            ComplexityEnabled = $Node.PasswordPolicy.ComplexityEnabled
            MinPasswordLength = $Node.PasswordPolicy.MinPasswordLength
            PasswordHistoryCount = $Node.PasswordPolicy.PasswordHistoryCount
            MaxPasswordAge = $Node.PasswordPolicy.MaxPasswordAge
            MinPasswordAge = $Node.PasswordPolicy.MinPasswordAge
            LockoutThreshold = $Node.PasswordPolicy.LockoutThreshold
            LockoutDuration = $Node.PasswordPolicy.LockoutDuration
            LockoutObservationWindow = $Node.PasswordPolicy.LockoutObservationWindow
            ReversibleEncryptionEnabled = $Node.PasswordPolicy.ReversibleEncryptionEnabled
            Credential = $DomainAdminCredential
            DependsOn = '[WaitForADDomain]WaitForBarmBuzz'
        }

        # ---------------- GPO CREATION ----------------
        foreach ($gpo in $Node.GroupPolicies) {
            GroupPolicy "GPO_$($gpo.Key)" {
                Name = $gpo.Name
                Ensure = 'Present'
                DependsOn = '[WindowsFeature]GPMC'
            }
        }

        # ---------------- GPO LINKS ----------------
        foreach ($link in $Node.GPOLinks) {
            $linkTarget = "$($link.TargetOUPath),$($Node.DomainDN)"
            GPLink "GPLink_$($link.Key)" {
                GPOName = $link.GPOName
                Path = $linkTarget
                Order = $link.Order
                Enforced = $link.Enforced
                Enabled = $link.LinkEnabled
                Ensure = 'Present'
                DependsOn = @(
                    "[GroupPolicy]GPO_$($link.DependsOnGPO)",
                    "[ADOrganizationalUnit]OU_$($link.DependsOnOUKey)"
                )
            }
        }

        # ---------------- GPO REGISTRY SETTINGS ----------------
        foreach ($regVal in $Node.GPORegistryValues) {
            GPRegistryValue "GPReg_$($regVal.Key)" {
                Name = $regVal.GPOName
                Key = $regVal.RegistryKey
                ValueName = $regVal.ValueName
                ValueType = $regVal.ValueType
                Value = $regVal.ValueData
                Ensure = 'Present'
                DependsOn = "[GroupPolicy]GPO_$($regVal.DependsOnGPO)"
            }
        }
    }
}