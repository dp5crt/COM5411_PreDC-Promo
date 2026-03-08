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

    Node $AllNodes.NodeName {
        # --- Networking (Aligned to NetworkingDsc 9.0.0) ---
        IPAddress InternalStaticIP {
            InterfaceAlias = $AllNodes.InterfaceAlias_Internal
            AddressFamily  = 'IPv4'
            IPAddress      = $AllNodes.IPv4Address_Internal # Exact match for your 9.0.0 module
        }

        DNSServerAddress InternalDNS {
            InterfaceAlias = $AllNodes.InterfaceAlias_Internal
            AddressFamily  = 'IPv4'
            Address        = $AllNodes.DnsServers_Internal # Exact match for your 9.0.0 module
            DependsOn      = '[IPAddress]InternalStaticIP'
        }

        # --- Active Directory (Aligned to ADDS 6.6.0) ---
        WindowsFeature ADDS {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature RSATADDS {
            Name   = 'RSAT-AD-Tools'
            Ensure = 'Present'
        }

# --- 2. Registry Fix (Uses NAT alias from AllNodes) ---
        Registry DisableNatDnsRegistration {
            Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($Node.InterfaceAlias_NAT)"
            ValueName = 'RegistrationEnabled'
            ValueData = '0'
            ValueType = 'Dword'
            Ensure    = 'Present'
            DependsOn = '[DNSServerAddress]InternalDNS'
        }

        ADDomain BarmBuzzDomain {
            DomainName                    = $AllNodes.DomainName
            DomainNetbiosName             = $AllNodes.DomainNetBIOSName
            DomainMode                    = $AllNodes.DomainMode
            ForestMode                    = $AllNodes.ForestMode
            Credential                    = $DomainAdminCredential # Exact match for your 6.6.0 module
            SafeModeAdministratorPassword = $DsrmCredential
            DependsOn                     = @('[WindowsFeature]ADDS', '[DNSServerAddress]InternalDNS')
        }
    }
}