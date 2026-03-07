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

        # --- Organizational Units (Standard Security Structure) ---
        # --- Organizational Units (Avoids conflicts with default system containers) ---
        ADOrganizationalUnit BarmBuzzGroups {
            Name       = 'BB_Groups'
            Path       = "DC=barmbuzz,DC=local"
            DependsOn  = '[ADDomain]BarmBuzzDomain'
            Ensure     = 'Present'
        }

        ADOrganizationalUnit BarmBuzzUsers {
            Name       = 'BB_Users'
            Path       = "DC=barmbuzz,DC=local"
            DependsOn  = '[ADDomain]BarmBuzzDomain'
            Ensure     = 'Present'
        }

        ADOrganizationalUnit BarmBuzzComputers {
            Name       = 'BB_Computers'
            Path       = "DC=barmbuzz,DC=local"
            DependsOn  = '[ADDomain]BarmBuzzDomain'
            Ensure     = 'Present'
        }
    }
}