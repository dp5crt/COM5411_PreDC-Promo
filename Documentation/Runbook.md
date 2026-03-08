# Runbook (Student)

Keep a dated log of:
- what you changed
- what you ran (commands)
- where the evidence is stored (paths)

Runbook Log 1
What I changed:
I created a file called test.txt inside my repository and staged it in VS Code. When VS Code wouldn’t allow me to commit, I ran diagnostics to understand why. I discovered that Git believed the file was inside a duplicated nested folder path (dp5crt-git-practice/dp5crt-git-practice/test.txt), which explained why the commit button was disabled.
What I ran (commands):
git status
git add test.txt
git add .
git commit -m "testing"
git rev-parse --show-toplevel
git --version
Where the evidence is stored:
Git log


Runbook Log 2
what I changed:
Removed a hidden duplicate Git repository that caused VS Code to loop
Cleared the broken git.path setting in VS Code
Terminated all VS Code background processes
Deleted VS Code’s corrupted Git cache (workspaceStorage)
Reloaded VS Code to rebuild Git state
what I ran (commands):
git --version
where git
git status
Get-ChildItem -Force
Remove-Item -Recurse -Force .git
tasklist | findstr git
taskkill /IM git.exe /F
Remove-Item -Recurse -Force "$env:APPDATA\Code\User\workspaceStorage"
where the evidence is stored:
Git log



Runbook Log 3
What I changed:
Identified that DSC v3 did not install successfully due to a Winget portable‑package copy failure.
Determined that the fix requires reinstalling with elevation and possibly clearing corrupted Winget package folders or resetting ACLs.
What I ran (commands):
(These are the commands I planned or prepared to run as part of the fix)
# Check DSC availability dsc --version # Attempt elevated reinstall winget install -e --id Microsoft.DSC # Remove corrupted package folder (if needed) Remove-Item -Recurse -Force "C:\Users\Daniel Penfold\AppData\Local\Microsoft\WinGet\Packages\Microsoft.DSC_Microsoft.WinGet.Source_8wekyb3d8bbwe" # Reset ACLs (if needed) icacls "$env:LOCALAPPDATA\Microsoft\WinGet" /reset /t
Where the evidence is stored:
Git log



Runbook Log 4
What I changed
Corrected the module installation path to the valid Windows PowerShell module directory:
C:\Program Files\WindowsPowerShell\Modules
What I ran (commands)
Commands executed during the session:
$Dest = "C:\ProgramFiles\WindowsPowershell\Modules" # incorrect path Save-PSResource -Name ActiveDirectoryDsc -Version 6.6.0 -Repository PSGallery -Path $Dest -TrustRepository
Planned corrected command:
$Dest = "C:\Program Files\WindowsPowerShell\Modules" Save-PSResource -Name ActiveDirectoryDsc -Version 6.6.0 -Repository PSGallery -Path $Dest -TrustRepository
Where the evidence is stored
Evidence is stored in the PowerShell terminal output visible in the screenshot:
Git log



Runbook Log 5
What I changed
I identified that the Pester test was enforcing DSC version 2.0.7, but PowerShell 7 was using 2.0.8.
I confirmed that installing 2.0.7 only affects Windows PowerShell, not pwsh.
I learned that PowerShell 7’s DSC version is built into the pwsh installation and cannot be overridden.
I concluded that the only valid fixes are:
Update the Pester test to expect 2.0.8,
or
Downgrade PowerShell 7 to 7.3.x (which ships with DSC 2.0.7).
What I ran (commands)
pwsh Get-Module PSDesiredStateConfiguration -ListAvailable
Install-Module PSDesiredStateConfiguration -RequiredVersion 2.0.7
$PSVersionTable
Where the evidence is stored
Git log



Runbook Log 6
What I changed:
Updated StudentBaseline configuration to include:
param( [PSCredential]$DomainAdminCredential, [PSCredential]$DsrmCredential )
Ensured the configuration uses $AllNodes.NodeName.
Corrected syntax errors in the parameter block.
Verified DSC resources and imports were valid.
Ensured the compile script passes both credentials.
What I ran (commands):
Recompiled the DSC configuration using PowerShell 5.1:
StudentBaseline -ConfigurationData $ConfigData -DomainAdminCredential $adminCred -DsrmCredential $dsrmCred
Applied the configuration:
Start-DscConfiguration -Path .\StudentBaseline -Wait -Verbose
Where the evidence is stored:
Git log



Runbook Log 7
What I changed
Identified that the Windows Time service was failing because DSC had never applied
Determined that the Outputs folder contained no compiled configuration
Confirmed that StudentBaseline contains the baseline MOF, not the applied MOF
Realised the fix was to compile StudentConfig.ps1 into Outputs
What I ran (commands)
Set-Location .\DSC . .\StudentConfig.ps1 StudentConfig -OutputPath .\Outputs Start-DscConfiguration -Path .\Outputs -Wait -Verbose -Force Get-Service W32Time | Select Status, StartType
Where the evidence is stored
Evidence of folder structure:
Git log




Runbook Log 8
What I changed:
Removed duplicate ComputerManagementDsc module from my user profile.
Reinstalled the module system‑wide.
Commands I ran:
Remove-Item -Recurse -Force "$HOME\Documents\PowerShell\Modules\ComputerManagementDsc" Uninstall-Module ComputerManagementDsc -AllVersions -Force Install-Module ComputerManagementDsc -Scope AllUsers -Force Get-DscResource -Module ComputerManagementDsc
Evidence stored:
Git log
WinRM Listener Reset
What I changed:
Deleted the stale WinRM listener.
Recreated a fresh listener using winrm quickconfig.
Commands I ran:
winrm delete winrm/config/listener?Address=*+Transport=HTTP winrm quickconfig winrm enumerate winrm/config/listener
Evidence stored:
Git log
DSC Connectivity Investigation
What I changed:
Began verifying hostname consistency across Windows, environment variables, and WinRM.
Commands I ran:
hostname $env:COMPUTERNAME winrm get winrm/config
Evidence stored:
Git log





Runbook Log 9
What I changed
I clarified my understanding of how to edit Git commits, including:
How to amend the most recent commit
How to edit older commits using interactive rebase
When force‑pushing is required
What I ran (commands)
These are the commands referenced in the conversation:
git commit --amend git add git rebase -i HEAD~N git commit --amend git rebase --continue git push --force-with-lease
Where the evidence is stored
Git log



Runbook Log 10
What You Changed: None in code; just requested documentation/logging.
What You Ran (Commands):
git add .
git commit -m "Your commit message"
git push origin main
git push -u origin main
Where the Evidence is Stored: 
Git log




Runbook Log 11
What I Changed:
Disabled the Internal Network adapter inside the VM.
Manually configured DNS to Google DNS (8.8.8.8 / 8.8.4.4).
Flushed DNS and reset Winsock.
What I Ran (Commands):
ipconfig /flushdns
netsh winsock reset
shutdown /r /t 0          # Restart VM
ping 8.8.8.8              # Test connectivity
ping google.com            # Test DNS resolution
nslookup google.com        # Test DNS server response
Where the Evidence is Stored:
Git log




Runbook Log 12
What I Changed:
Elevated PowerShell permissions to Administrator to modify system-wide settings.
Adjusted the script execution environment to bypass local restrictions.
What you Ran (Commands):
Set-ExecutionPolicy RemoteSigned
Get-ExecutionPolicy -List
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
(Get-CimInstance Win32_OperatingSystem).Caption
Get-WmiObject Win32_OperatingSystem | Select-Object Caption
Where the Evidence is Stored:
Git log




Runbook Log 13
What I Changed: * Modified the Node declaration in StudentConfig.ps1 to properly handle the ConfigurationData string.
Updated IPAddress, DNSServerAddress, and DnsClient resources to use $Node.InterfaceAlias_Internal and $Node.InterfaceAlias_NAT instead of the $AllNodes array.
Ensured the ADDomain resource used $Node for domain identity properties (DomainName, NetBIOSName, etc.).
What you Ran (Commands): * Ran the build orchestrator (e.g., .\Run_BuildMain.ps1) to trigger the DSC compilation.
Used Get-Module -Name PSDesiredStateConfiguration -ListAvailable to verify system module paths.
Where the Evidence is Stored: 
Git log



Runbook Log 14
What I Changed:
Data Updates: Modified Data\AllNodes.psd1 by adding GroupScope = 'Global' to groups and explicit DomainName keys to user objects to meet ActiveDirectoryDsc requirements.
Configuration Logic: Updated Configurations\StudentConfig.ps1 by nesting the group membership properties inside an explicit ADGroupMember resource block.
Hierarchy Fix: Added the missing Sites OU to the data file so the Bolton OU has a valid parent path during the build.
What I Ran (Commands):
.\Build.ps1 (to trigger the DSC compilation and MOF generation).
Invoke-Pester (intended command to validate infrastructure, currently pending the $OUs variable fix).
Where the Evidence is Stored:
Git log



Runbook Log 15
What I Changed:
Password Policy: Set MinPasswordLength to 10, LockoutThreshold to 5, and disabled ReversibleEncryptionEnabled.
GPO Creation: Defined four base policies: BB_Workstations_Baseline, BB_Servers_Baseline, BB_POS_Lockdown, and BB_AllUsers_Banner.
Registry Hardening: * Disabled LM Hash storage and SMBv1.
Enforced SMB Signing and NTLMv2 only.
Configured a 10-minute screensaver timeout.
Compliance: Configured legal notice banners for POS terminals and the wider organization.
Security Filtering: Added a GPO permission entry for the GG_BB_Bolton_Baristas group to the POS Lockdown policy.
What I Ran (Commands):
No commands were executed in this session; the configuration was prepared for a PowerShell DSC deployment. The intended command for deployment would be: Start-DscConfiguration -Path .\BarmBuzzConfig -Wait -Verbose
Where the Evidence is Stored:
Git log



Runbook Log 16
What I Changed:
Data Structure: Converted AllNodes.psd1 into a static, valid PowerShell Data File by ensuring it only contains a single hashtable without dynamic logic.
Syntax Correction: Closed the nested foreach loops and the main Configuration block to allow the PowerShell engine to recognize the StudentBaseline command.
User Attributes: Corrected the ADUser property mapping to ensure successful attribute synchronization.
What I Ran (Commands):
No deployment commands were executed in this session; the code was prepared for the following compilation command: StudentBaseline -ConfigurationData "C:\Dev\repos\COM5411_PreDC-Promo\DSC\Data\AllNodes.psd1".
Where the Evidence is Stored:
Git log