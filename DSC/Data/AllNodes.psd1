@{
    AllNodes = @(
        @{
            # --- Identification ---
            NodeName     = 'localhost'
            Role         = 'DC'
            ComputerName = 'BB-DC01'

            # --- Active Directory Settings ---
            DomainName        = 'barmbuzz.local'
            DomainNetBIOSName = 'BARMBUZZ'
            DomainDN          = 'DC=barmbuzz,DC=local'
            JoinOU = 'OU=Windows,OU=Clients,OU=BarmBuzz,DC=barmbuzz,DC=local'
            ForestMode = 'WinThreshold'
            DomainMode = 'WinThreshold'

            # --- Computer Settings ---
            TimeZone = 'GMT Standard Time'

            # --- Network Settings (Internal NIC) ---
            InterfaceAlias_Internal = 'Ethernet 2'
            IPv4Address_Internal    = '192.168.99.10'
            PrefixLength_Internal   = 24
            DnsServers_Internal     = @('127.0.0.1')

            # --- Network Settings (NAT NIC) ---
            InterfaceAlias_NAT          = 'Ethernet'
            Expect_NAT_Dhcp             = $true
            DisableDnsRegistrationOnNat = $true

            # --- Installation Flags ---
            InstallADDSRole = $true
            InstallRSATADDS = $true
            PsDscAllowPlainTextPassword = $true
            PsDscAllowDomainUser         = $true

            OrgName   = 'BarmBuzz'
            OrgPrefix = 'BB'

            # ------------------------------------------------------------
            # ORGANIZATIONAL UNITS
            # ------------------------------------------------------------
            OrganizationalUnits = @(
                @{ Key='BarmBuzz'; Name='BarmBuzz'; ParentPath=''; DependsOnKey=$null; Protected=$true; Description='Root container for BarmBuzz resources' }
                @{ Key='Tier0'; Name='Tier0'; ParentPath='OU=BarmBuzz'; DependsOnKey='BarmBuzz'; Protected=$true; Description='Identity and Domain Management Assets' }
                @{ Key='Tier0_Admin'; Name='Admins'; ParentPath='OU=Tier0,OU=BarmBuzz'; DependsOnKey='Tier0'; Protected=$true; Description='Privileged Administrator Accounts' }
                @{ Key='Tier0_Servers'; Name='Servers'; ParentPath='OU=Tier0,OU=BarmBuzz'; DependsOnKey='Tier0'; Protected=$true; Description='Domain Controllers and Infrastructure Servers' }
                @{ Key='Tier0_ServiceAccounts'; Name='ServiceAccounts'; ParentPath='OU=Tier0,OU=BarmBuzz'; DependsOnKey='Tier0'; Protected=$true; Description='High-privilege Service Accounts' }
                @{ Key='Sites'; Name='Sites'; ParentPath='OU=BarmBuzz'; DependsOnKey='BarmBuzz'; Protected=$true; Description='Geographic Business Locations' }
                @{ Key='Bolton'; Name='Bolton'; ParentPath='OU=Sites,OU=BarmBuzz'; DependsOnKey='Sites'; Protected=$true; Description='Bolton Depot Site' }
                @{ Key='Bolton_Users'; Name='Users'; ParentPath='OU=Bolton,OU=Sites,OU=BarmBuzz'; DependsOnKey='Bolton'; Protected=$true; Description='Standard Users based in Bolton' }
                @{ Key='Bolton_Computers'; Name='Computers'; ParentPath='OU=Bolton,OU=Sites,OU=BarmBuzz'; DependsOnKey='Bolton'; Protected=$true; Description='Bolton Site Computer Resources' }
                @{ Key='Bolton_Workstations'; Name='Workstations'; ParentPath='OU=Computers,OU=Bolton,OU=Sites,OU=BarmBuzz'; DependsOnKey='Bolton_Computers'; Protected=$true; Description='General Office Workstations' }
                @{ Key='Bolton_POS'; Name='POS'; ParentPath='OU=Computers,OU=Bolton,OU=Sites,OU=BarmBuzz'; DependsOnKey='Bolton_Computers'; Protected=$true; Description='Point of Sale Terminals' }
                @{ Key='Bolton_Kiosks'; Name='Kiosks'; ParentPath='OU=Computers,OU=Bolton,OU=Sites,OU=BarmBuzz'; DependsOnKey='Bolton_Computers'; Protected=$true; Description='Public Facing Information Kiosks' }
                @{ Key='Groups'; Name='Groups'; ParentPath='OU=BarmBuzz'; DependsOnKey='BarmBuzz'; Protected=$true; Description='Security and Distribution Group Container' }
                @{ Key='Groups_Role'; Name='Role'; ParentPath='OU=Groups,OU=BarmBuzz'; DependsOnKey='Groups'; Protected=$true; Description='Groups defined by Job Function' }
                @{ Key='Groups_Resource'; Name='Resource'; ParentPath='OU=Groups,OU=BarmBuzz'; DependsOnKey='Groups'; Protected=$true; Description='Groups providing Access to Specific Resources' }
                @{ Key='Clients'; Name='Clients'; ParentPath='OU=BarmBuzz'; DependsOnKey='BarmBuzz'; Protected=$true; Description='Managed Client Device Container' }
                @{ Key='Clients_Windows'; Name='Windows'; ParentPath='OU=Clients,OU=BarmBuzz'; DependsOnKey='Clients'; Protected=$true; Description='Managed Windows Clients' }
                @{ Key='Clients_Linux'; Name='Linux'; ParentPath='OU=Clients,OU=BarmBuzz'; DependsOnKey='Clients'; Protected=$true; Description='Managed Linux Clients' }
            )

            # ------------------------------------------------------------
            # SECURITY GROUPS
            # ------------------------------------------------------------
            SecurityGroups = @(
                @{ Key='GG_Bolton_Baristas'; GroupName='GG_BB_Bolton_Baristas'; GroupScope='Global'; Category='Security'; OUPath='OU=Role,OU=Groups,OU=BarmBuzz'; DependsOnOUKey='Groups_Role'; MembersToInclude=$null; Description='Standard Barista Staff for Bolton site' }
                @{ Key='GG_Bolton_Managers'; GroupName='GG_BB_Bolton_Managers'; GroupScope='Global'; Category='Security'; OUPath='OU=Role,OU=Groups,OU=BarmBuzz'; DependsOnOUKey='Groups_Role'; MembersToInclude=$null; Description='Depot and Shift Managers for Bolton site' }
                @{ Key='GG_IT_Helpdesk'; GroupName='GG_BB_IT_Helpdesk'; GroupScope='Global'; Category='Security'; OUPath='OU=Role,OU=Groups,OU=BarmBuzz'; DependsOnOUKey='Groups_Role'; MembersToInclude=$null; Description='Internal IT Support Personnel' }
                @{ Key='DL_POS_LocalAdmins'; GroupName='DL_BB_POS_LocalAdmins'; GroupScope='DomainLocal'; Category='Security'; OUPath='OU=Resource,OU=Groups,OU=BarmBuzz'; DependsOnOUKey='Groups_Resource'; MembersToInclude=@('GG_BB_Bolton_Baristas'); Description='Grants Local Admin rights on POS terminals' }
                @{ Key='DL_Recipes_Read'; GroupName='DL_BB_Recipes_Read'; GroupScope='DomainLocal'; Category='Security'; OUPath='OU=Resource,OU=Groups,OU=BarmBuzz'; DependsOnOUKey='Groups_Resource'; MembersToInclude=@('GG_BB_Bolton_Baristas','GG_BB_Bolton_Managers'); Description='Read-only access to Barm Recipe repository' }
                @{ Key='DL_Recipes_Write'; GroupName='DL_BB_Recipes_Write'; GroupScope='DomainLocal'; Category='Security'; OUPath='OU=Resource,OU=Groups,OU=BarmBuzz'; DependsOnOUKey='Groups_Resource'; MembersToInclude=@('GG_BB_Bolton_Managers'); Description='Full write access to Barm Recipe repository' }
            )

            # ------------------------------------------------------------
            # DELEGATION
            # ------------------------------------------------------------
            Delegations = @(
                @{
                    Key='Delegate_Workstation_Join'
                    TargetOUPath='OU=Workstations,OU=Computers,OU=Bolton,OU=Sites,OU=BarmBuzz'
                    IdentityGroupName='GG_BB_IT_Helpdesk'
                    DependsOnOUKey='Bolton_Workstations'
                    DependsOnGroupKey='GG_IT_Helpdesk'
                    Rights=@('CreateChild','DeleteChild')
                    AccessControlType='Allow'
                    ObjectTypeGuid='bf967a86-0de6-11d0-a285-00aa003049e2'
                    InheritanceType='All'
                    InheritedObjectType='00000000-0000-0000-0000-000000000000'
                    Description='Allows Helpdesk to join computers to the Workstations OU'
                }
            )

            # ------------------------------------------------------------
            # USERS
            # ------------------------------------------------------------
            ADUsers = @(
                @{
                    Key='kat_barista'
                    UserName='kat.barista'; GivenName='Kat'; Surname='Barista'; DisplayName='Kat Barista'; UserPrincipalName='kat.barista@barmbuzz.local'
                    OUPath='OU=Users,OU=Bolton,OU=Sites,OU=BarmBuzz'; DependsOnOUKey='Bolton_Users'; GroupMembership=@('GG_BB_Bolton_Baristas')
                    JobTitle='Senior Barista'; Department='Barm Assembly'; Description='Bolton barista HVBSDP certified'; ChangePasswordAtLogon=$true
                }
                @{
                    Key='ben_manager'
                    UserName='ben.manager'; GivenName='Ben'; Surname='Manager'; DisplayName='Ben Manager'; UserPrincipalName='ben.manager@barmbuzz.local'
                    OUPath='OU=Users,OU=Bolton,OU=Sites,OU=BarmBuzz'; DependsOnOUKey='Bolton_Users'; GroupMembership=@('GG_BB_Bolton_Managers')
                    JobTitle='Depot Manager'; Department='Operations'; Description='Bolton depot manager - route supervisor'; ChangePasswordAtLogon=$true
                }
                @{
                    Key='max_helpdesk'
                    UserName='max.helpdesk'; GivenName='Max'; Surname='Helpdesk'; DisplayName='Max Helpdesk'; UserPrincipalName='max.helpdesk@barmbuzz.local'
                    OUPath='OU=Users,OU=Bolton,OU=Sites,OU=BarmBuzz'; DependsOnOUKey='Bolton_Users'; GroupMembership=@('GG_BB_IT_Helpdesk')
                    JobTitle='IT Helpdesk Analyst'; Department='IT'; Description='IT helpdesk - delegated workstation and user support'; ChangePasswordAtLogon=$true
                }
            )

            # ------------------------------------------------------------
            # PASSWORD POLICY (FIXED FOR COMPLEXITY ERRORS)
            # ------------------------------------------------------------
            PasswordPolicy = @{
                # Change ComplexityEnabled to $false so it stops rejecting simple passwords
                ComplexityEnabled           = $false 
                
                # Lower MinPasswordLength to a smaller value (e.g., 1 or 6)
                MinPasswordLength           = 1 
                
                PasswordHistoryCount        = 0
                MaxPasswordAge              = 129600
                MinPasswordAge              = 1440
                LockoutThreshold            = 5
                LockoutDuration             = 30
                LockoutObservationWindow    = 30
                ReversibleEncryptionEnabled = $false
            }

            # ------------------------------------------------------------
            # GROUP POLICIES
            # ------------------------------------------------------------
            GroupPolicies = @(
                @{ Key='GPO_Workstations_Baseline'; Name='BB_Workstations_Baseline'; Description='Standard security hardening for all Windows 10/11 workstations' }
                @{ Key='GPO_Servers_Baseline'; Name='BB_Servers_Baseline'; Description='Infrastructure server security and remote management configuration' }
                @{ Key='GPO_POS_Lockdown'; Name='BB_POS_Lockdown'; Description='Restricted shell and USB blocking for Point of Sale systems' }
                @{ Key='GPO_AllUsers_Banner'; Name='BB_AllUsers_Banner'; Description='Legal notification and acceptable use banner for all logons' }
            )

            # ------------------------------------------------------------
            # GPO LINKS
            # ------------------------------------------------------------
            GPOLinks = @(
                @{ Key='Link_WksBaseline_Workstations'; GPOName='BB_Workstations_Baseline'; TargetOUPath='OU=Workstations,OU=Computers,OU=Bolton,OU=Sites,OU=BarmBuzz'; DependsOnGPO='GPO_Workstations_Baseline'; DependsOnOUKey='Bolton_Workstations'; Order=1; Enforced='No'; LinkEnabled='Yes' }
                @{ Key='Link_SrvBaseline_Servers'; GPOName='BB_Servers_Baseline'; TargetOUPath='OU=Servers,OU=Tier0,OU=BarmBuzz'; DependsOnGPO='GPO_Servers_Baseline'; DependsOnOUKey='Tier0_Servers'; Order=1; Enforced='No'; LinkEnabled='Yes' }
                @{ Key='Link_POSLockdown_POS'; GPOName='BB_POS_Lockdown'; TargetOUPath='OU=POS,OU=Computers,OU=Bolton,OU=Sites,OU=BarmBuzz'; DependsOnGPO='GPO_POS_Lockdown'; DependsOnOUKey='Bolton_POS'; Order=1; Enforced='Yes'; LinkEnabled='Yes' }
                @{ Key='Link_Banner_BarmBuzz'; GPOName='BB_AllUsers_Banner'; TargetOUPath='OU=BarmBuzz'; DependsOnGPO='GPO_AllUsers_Banner'; DependsOnOUKey='BarmBuzz'; Order=1; Enforced='No'; LinkEnabled='Yes' }
            )

            # ------------------------------------------------------------
            # GPO REGISTRY VALUES
            # ------------------------------------------------------------
            GPORegistryValues = @(
                @{ Key='Wks_NoLMHash'; GPOName='BB_Workstations_Baseline'; DependsOnGPO='GPO_Workstations_Baseline'; RegistryKey='HKLM\System\CurrentControlSet\Control\Lsa'; ValueName='NoLMHash'; ValueType='Dword'; ValueData='1'; Description='Prevents storage of LAN Manager password hashes' }
                @{ Key='Wks_SMBSigning'; GPOName='BB_Workstations_Baseline'; DependsOnGPO='GPO_Workstations_Baseline'; RegistryKey='HKLM\System\CurrentControlSet\Services\LanManServer\Parameters'; ValueName='RequireSecuritySignature'; ValueType='Dword'; ValueData='1'; Description='Mandates SMB signing to prevent man-in-the-middle attacks' }
                @{ Key='Srv_SMB1Disable'; GPOName='BB_Servers_Baseline'; DependsOnGPO='GPO_Servers_Baseline'; RegistryKey='HKLM\System\CurrentControlSet\Services\LanManServer\Parameters'; ValueName='SMB1'; ValueType='Dword'; ValueData='0'; Description='Disables the legacy and insecure SMBv1 protocol' }
            )

            DefaultComputerOU = 'OU=Windows,OU=Clients,OU=BarmBuzz'

            ADComputers = @(
                @{ Key='BB_WIN11_01'; ComputerName='BB_WIN11_01'; OUPath='OU=Windows,OU=Clients,OU=BarmBuzz'; DependsOnOUKey='Clients_Windows'; Description='Primary Windows 11 Administration Client' }
                @{ Key='BB_LNX_01'; ComputerName='BB_LNX_01'; OUPath='OU=Linux,OU=Clients,OU=BarmBuzz'; DependsOnOUKey='Clients_Linux'; Description='Linux Development and Testing Client' }
            )
        }
    )
}