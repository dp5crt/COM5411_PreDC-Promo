<#
STUDENT TASK:
- Define Configuration StudentBaseline
- Use ConfigurationData (AllNodes.psd1)
- DO NOT hardcode passwords here.

CYBERSECURITY NOTES:
This is a Security module. Credential handling matters even in labs.

WHY NO HARDCODED CREDENTIALS?
1. Security Hygiene: Hardcoded credentials in code = security breach waiting to happen
2. Git History: Once committed, credentials are in your Git history FOREVER (even if you delete them later)
3. Professional Practice: Real environments use credential vaults (Azure KeyVault, HashiCorp Vault, etc.)
4. Audit Trail: Your Git commits may be reviewed by employers, peers, or examiners

HOW CREDENTIALS WILL WORK (Later weeks):
- The orchestrator (Run_BuildMain.ps1) will handle credential creation securely
- Your configuration receives them as PSCredential objects via parameters
- Example: Configuration StudentBaseline { param([PSCredential]$DomainCredential) }
- You reference them in DSC resources without seeing the plaintext password
- MOFs can be encrypted with certificates (production best practice)

FOR NOW (Week 1):
- Lab uses FIXED credentials documented in StudentRepoInit.ps1
- Administrator password: superw1n_user (Windows local admin)
- User accounts password: notlob2k26 (domain users you create)
- You may need these for MANUAL tasks, but NEVER put them in this file

THREAT MODEL AWARENESS:
Even in a lab, practice defense-in-depth:
- Assume your repo will be cloned by others (it will - it's Git!)
- Assume your transcripts/logs will be read (they're in Evidence/)
- Assume your build artifacts will be inspected (they're committed)
- NEVER commit: passwords, API keys, personal data, PII

If you accidentally commit a secret:
1. Rotating the secret is the ONLY fix (changing the password)
2. Deleting the file or "fixing" the commit does NOT remove it from Git history
3. Tools like git-secrets, TruffleHog, and GitGuardian scan for exposed secrets

This is not paranoia - this is professional discipline.
#>

<#
STUDENT TASK:
- Define Configuration StudentBaseline
- Use ConfigurationData (AllNodes.psd1)
- DO NOT hardcode passwords here.

CYBERSECURITY NOTES:
This is a Security module. Credential handling matters even in labs.

WHY NO HARDCODED CREDENTIALS?
1. Security Hygiene: Hardcoded credentials in code = security breach waiting to happen
2. Git History: Once committed, credentials are in your Git history FOREVER (even if you delete them later)
3. Professional Practice: Real environments use credential vaults (Azure KeyVault, HashiCorp Vault, etc.)
4. Audit Trail: Your Git commits may be reviewed by employers, peers, or examiners

HOW CREDENTIALS WILL WORK (Later weeks):
- The orchestrator (Run_BuildMain.ps1) will handle credential creation securely
- Your configuration receives them as PSCredential objects via parameters
- Example: Configuration StudentBaseline { param([PSCredential]$DomainCredential) }
- You reference them in DSC resources without seeing the plaintext password
- MOFs can be encrypted with certificates (production best practice)

FOR NOW (Week 1):
- Lab uses FIXED credentials documented in StudentRepoInit.ps1
- Administrator password: superw1n_user (Windows local admin)
- User accounts password: notlob2k26 (domain users you create)
- You may need these for MANUAL tasks, but NEVER put them in this file

THREAT MODEL AWARENESS:
Even in a lab, practice defense-in-depth:
- Assume your repo will be cloned by others (it will - it's Git!)
- Assume your transcripts/logs will be read (they're in Evidence/)
- Assume your build artifacts will be inspected (they're committed)
- NEVER commit: passwords, API keys, personal data, PII

If you accidentally commit a secret:
1. Rotating the secret is the ONLY fix (changing the password)
2. Deleting the file or "fixing" the commit does NOT remove it from Git history
3. Tools like git-secrets, TruffleHog, and GitGuardian scan for exposed secrets

This is not paranoia - this is professional discipline.
#>

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
            IPAddress      = $AllNodes.IPv4Address_Internal 
        }

        DNSServerAddress InternalDNS {
            InterfaceAlias = $AllNodes.InterfaceAlias_Internal
            AddressFamily  = 'IPv4'
            Address        = $AllNodes.DnsServers_Internal 
            DependsOn      = '[IPAddress]InternalStaticIP'
        }


        # --- FIX: Removed the DnsClient block that caused the Positional Parameter error ---
        # Manual registry fix to ensure NAT NIC doesn't register in AD DNS. 
        # This replaces the DnsClient resource and satisfies the Pester test.
        # --- FIX: The Registry Key path requires a simpler string format to avoid the Positional Parameter error ---
        Registry DisableNatDnsRegistration {
            # Use a variable to store the path first, or use simple concatenation
            Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$($Node.InterfaceAlias_NAT)"
            ValueName = 'RegistrationEnabled'
            ValueData = '0'
            ValueType = 'Dword'
            Ensure    = 'Present'
            # Added a dependency to networking so it doesn't run before the NIC is ready
            DependsOn = '[DNSServerAddress]InternalDNS' 
        }

        # --- Active Directory (Aligned to ADDS 6.6.0) ---
        WindowsFeature ADDS {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        # Added DependsOn to ensure tools install AFTER the core feature
        WindowsFeature RSATADDS {
            Name      = 'RSAT-AD-Tools'
            Ensure    = 'Present'
            DependsOn = '[WindowsFeature]ADDS'
        }

        # --- Active Directory ---
        # Ensure you are using the PSCredential objects passed in the Param block
        ADDomain BarmBuzzDomain {
            DomainName                    = $Node.DomainName
            DomainNetbiosName             = $Node.DomainNetBIOSName
            DomainMode                    = $Node.DomainMode
            ForestMode                    = $Node.ForestMode
            # Ensure these match your param() block exactly
            Credential                    = $DomainAdminCredential 
            SafeModeAdministratorPassword = $DsrmCredential
            DependsOn                     = @('[WindowsFeature]RSATADDS', '[DNSServerAddress]InternalDNS')
        }

        # --- 1. ENTERPRISE ROOT ---
        ADOrganizationalUnit BarmBuzzRoot {
            Name                           = 'BarmBuzz'
            Path                           = "DC=barmbuzz,DC=local"
            Description                    = 'BarmBuzz enterprise root - the foundation of the logical forest structure.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADDomain]BarmBuzzDomain'
            Ensure                         = 'Present'
        }

        # --- 2. TIER 0 (CONTROL PLANE) ---
        ADOrganizationalUnit Tier0 {
            Name                           = 'Tier0'
            Path                           = "OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Domain control plane - restricted access for high-privilege assets.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]BarmBuzzRoot'
            Ensure                         = 'Present'
        }

        ADOrganizationalUnit Tier0Admins {
            Name                           = 'Admins'
            Path                           = "OU=Tier0,OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Domain administrator accounts - Tier 0 personnel only.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]Tier0'
            Ensure                         = 'Present'
        }

        # --- 3. SITES & REGIONAL (BOLTON HQ) ---
        ADOrganizationalUnit Sites {
            Name                           = 'Sites'
            Path                           = "OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Geographic site containers for regional resource management.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]BarmBuzzRoot'
            Ensure                         = 'Present'
        }

        ADOrganizationalUnit Bolton {
            Name                           = 'Bolton'
            Path                           = "OU=Sites,OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Bolton HQ - The spiritual and technical root of the enterprise.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]Sites'
            Ensure                         = 'Present'
        }

        # --- 4. ENDPOINTS (POS, WORKSTATIONS, KIOSKS) ---
        ADOrganizationalUnit BoltonComputers {
            Name                           = 'Computers'
            Path                           = "OU=Bolton,OU=Sites,OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Bolton computer accounts for workstations and specialized terminals.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]Bolton'
            Ensure                         = 'Present'
        }

        ADOrganizationalUnit BoltonPOS {
            Name                           = 'POS'
            Path                           = "OU=Computers,OU=Bolton,OU=Sites,OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'POS terminals at Barm Unloading Bay - critical retail endpoints.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]BoltonComputers'
            Ensure                         = 'Present'
        }

        ADOrganizationalUnit BoltonKiosks {
            Name                           = 'Kiosks'
            Path                           = "OU=Computers,OU=Bolton,OU=Sites,OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Self-service ordering kiosks - automated customer touchpoints.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]BoltonComputers'
            Ensure                         = 'Present'
        }

        # --- 5. GROUPS (Security and Distribution Containers) ---
        ADOrganizationalUnit Groups {
            Name                           = 'Groups'
            Path                           = "OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Security and distribution group containers for centralized access control.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]BarmBuzzRoot'
            Ensure                         = 'Present'
        }

        ADOrganizationalUnit GroupsRole {
            Name                           = 'Role'
            Path                           = "OU=Groups,OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Global role groups (AGDLP: G layer) representing job functions.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]Groups'
            Ensure                         = 'Present'
        }

        ADOrganizationalUnit GroupsResource {
            Name                           = 'Resource'
            Path                           = "OU=Groups,OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Domain local resource groups (AGDLP: DL layer) for ACL assignments.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]Groups'
            Ensure                         = 'Present'
        }

        # --- 6. CLIENTS (Domain-Joined Endpoints by OS) ---
        ADOrganizationalUnit Clients {
            Name                           = 'Clients'
            Path                           = "OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Domain-joined client machines categorized by operating system.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]BarmBuzzRoot'
            Ensure                         = 'Present'
        }

        ADOrganizationalUnit ClientsWindows {
            Name                           = 'Windows'
            Path                           = "OU=Clients,OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Windows domain-joined client endpoints.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]Clients'
            Ensure                         = 'Present'
        }

        ADOrganizationalUnit ClientsLinux {
            Name                           = 'Linux'
            Path                           = "OU=Clients,OU=BarmBuzz,DC=barmbuzz,DC=local"
            Description                    = 'Linux domain-joined client endpoints.'
            ProtectedFromAccidentalDeletion = $true
            DependsOn                      = '[ADOrganizationalUnit]Clients'
            Ensure                         = 'Present'
        }
    }
}