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

        # Set the computer name
        Computer SetName {
            Name = $AllNodes.ComputerName
        }

        # Set the TimeZone
        TimeZone SetTimeZone {
            IsSingleInstance = 'Yes'
            TimeZone = $AllNodes.TimeZone
        }

        # Ensure Time Service is running
        Service WindowsTime {
            Name        = 'W32Time'
            State       = 'Running'
            StartupType = 'Automatic'
            DependsOn   = '[TimeZone]SetTimeZone'
        }

        # Install AD DS Role (Correct Name)
        WindowsFeature ADDS {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        # Install RSAT Tools
        WindowsFeature RSATADDS {
            Name      = 'RSAT-AD-Tools'
            Ensure    = 'Present'
            DependsOn = '[WindowsFeature]ADDS'
        }

        # --- NETWORKING LOGIC ---

        # 1. Set Static IP for Internal NIC
       # 1. Set Static IP for Internal NIC (Ethernet 2)
        # Fix: Using 'IPAddress' property instead of 'IPv4Address'
        IPAddress InternalStaticIP {
            InterfaceAlias = $AllNodes.InterfaceAlias_Internal
            AddressFamily  = 'IPv4'
            IPAddress      = $AllNodes.IPv4Address_Internal # Corrected property name
        }

        # 2. Set DNS for Internal NIC
        # Fix: Using 'Address' property instead of 'AddressServer'
        DNSServerAddress InternalDNS {
            InterfaceAlias = $AllNodes.InterfaceAlias_Internal
            AddressFamily  = 'IPv4'
            Address        = $AllNodes.DnsServers_Internal # Corrected property name
            DependsOn      = '[IPAddress]InternalStaticIP'
        }

        # 3. Disable DNS Registration on NAT (Ethernet)
        DnsClient DisableNatRegistration {
            InterfaceAlias                 = $AllNodes.InterfaceAlias_NAT
            ConnectionSpecificSuffix           = ''
            RegisterThisConnectionsAddress = $false
            DependsOn                      = '[DNSServerAddress]InternalDNS' 
        }
    }
}