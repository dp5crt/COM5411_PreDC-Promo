# AI Usage Log (AI_LOG)

Record any AI/tool usage:
- date/time
- tool used
- what it generated
- what you changed afterwards

AI Log 1
Tool used:
Copilot
What it generated:
I asked Copilot how to add a text file to a Git repository in VS Code, why my commit wasn’t being accepted, and why commits sometimes appear slow. Copilot analysed my screenshot, identified that Git thought my file was inside a nested folder, and explained how that breaks VS Code’s commit workflow.
What I changed afterwards:
I provided a screenshot of my VS Code window, ran git status, and then asked Copilot to summarise the session in a structured log format.



AI Log 2
Tool used: Copilot
what it generated:
Explanations of Git errors
Diagnosis of nested Git repositories
Instructions to remove hidden folders
Instructions to reset VS Code Git cache
Steps to fix git.path misconfiguration
what I changed afterwards:
Removed nested .git folder
Cleared the incorrect git.path setting
Killed background VS Code processes
Deleted workspaceStorage to reset Git cache
Reloaded VS Code to rebuild Git integration

what I changed:
Removed a hidden duplicate Git repository that caused VS Code to loop
Cleared the broken git.path setting in VS Code
Terminated all VS Code background processes




AI Log 3 
Tool Used: Copilot
What it generated:
An explanation that DSC wasn’t installed because Winget failed with an “Access is denied” error.
A breakdown of why the install failed (permissions, locked folders, elevation).
A remediation plan including elevated reinstall, clearing the Winget package folder, resetting ACLs, and manual install options.
What I changed afterwards:
I refined the request into a structured summary format (AI usage log + runbook log).
I didn’t modify the technical content itself, only reorganised it into the requested format.



AI Log 4
Tool Used: Copilot
What it generated:
Output confirming RSAT capabilities installed successfully
An error from Save-PSResource stating the path did not exist
What I changed afterwards:
I corrected the destination path from
C:\ProgramFiles\WindowsPowershell\Modules
to
C:\Program Files\WindowsPowerShell\Modules
I prepared to rerun the Save-PSResource command with the correct path



AI Log 5

I asked the AI why my Pester test was failing.
It generated an explanation that PowerShell 7 was reporting PSDesiredStateConfiguration 2.0.8 instead of 2.0.7, which the test expected.
Afterwards, I clarified that installing 2.0.7 didn’t fix it.
I asked how to fix the mismatch.
The AI generated a deeper explanation that 2.0.7 cannot be installed into PowerShell 7 because the module was removed from the Gallery.
I then asked how to specifically change PowerShell 7.
I asked again how to change pwsh.
The AI generated a breakdown showing that PowerShell 7 ships DSC as a built‑in module, so the version is tied to the PowerShell build.
I then provided a screenshot of the module folders.
I showed the folder structure.
The AI generated an explanation that the folders I was looking at belonged to Windows PowerShell, not PowerShell 7, and that pwsh loads its own internal module.
Afterwards, I asked for a summary.





AI Log 6
Tool used: Copilot
What it generated:
Identified the root cause of the DSC compile failure (missing parameter in StudentBaseline).
Explained the purpose of DomainAdminCredential.
Reviewed the DSC configuration and highlighted syntax issues (missing comma).
Provided corrected configuration structure.
Clarified how the compile script must pass parameters.
What I changed afterwards:
Added the missing parameter block to the configuration.
Corrected the syntax error by adding a comma between parameters.
Ensured the configuration aligns with assignment requirements (no hardcoded passwords, uses ConfigurationData).
Updated the compile script to pass both credentials.




AI Log 7
Entry 1
Tool used: Copilot
What it generated: An explanation of why the Windows Time service test was failing
What I changed afterwards: I clarified that the DSC configuration had not been applied
Entry 2
Tool used: Copilot
What it generated: Guidance on compiling and applying DSC
What I changed afterwards: I corrected my assumption about folder structure after seeing your screenshots
Entry 3
Tool used: Copilot
What it generated: Diagnosis that the Outputs folder was empty
What I changed afterwards: I updated the explanation to reflect that your StudentConfig.ps1 had not compiled
Entry 4
Tool used: Copilot
What it generated: Final instructions to compile StudentConfig.ps1 into the Outputs folder
What I changed afterwards: I aligned the explanation with your actual repo structure (DSC → Outputs → StudentBaseline)





AI Log 8
date/time – tool used – what it generated – what I changed afterwards
Copilot Chat – Troubleshooting guidance
Generated explanations about PowerShell execution policies and DSC module conflicts.
I adjusted my steps after discovering two module paths existed and removed the user‑profile copy.
Copilot Chat – WinRM diagnostics
Generated commands to inspect WinRM listeners and identify hostname binding issues.
I refined the commands after seeing errors with the URI format and added the correct deletion syntax.
Copilot Chat – Listener recreation guidance
Generated instructions to delete and recreate the WinRM listener.
I updated the approach when the listener recreated without a hostname, confirming wildcard listener behaviour and shifting focus to hostname mismatch checks.
Copilot Chat – Final diagnostic plan
Generated a set of verification commands (hostname, $env:COMPUTERNAME, winrm get winrm/config).
I prepared to compare these values to identify the remaining DSC connectivity issue.




AI Log 9
Copilot text generation –
It generated an explanation of how to edit a Git commit (amend, interactive rebase, force‑push).
What I changed afterwards:
I didn’t modify the generated content; I simply read it.
Copilot text generation –
It generated this summary in the required two‑part format.
What I changed afterwards:
No changes; this is the final output.





AI Log 10
Tool Used: ChatGPT (GPT-5 mini)
What it Generated: Instructions and commands to push code to GitHub, including git add, git commit, git push origin main, explanations of origin, main, and -u option.
What You Changed Afterwards: None — you asked for a summarized log in your specified format.





AI Log 11
Tool Used: ChatGPT 
What it Generated:
Suggested that my VM had no network and recommended checking VirtualBox/VMware network adapter settings (NAT vs Internal).
Advised running ping 8.8.8.8 and ipconfig /release /renew.
Explained DNS issues and that having two adapters could cause Windows to prioritize the wrong one.
Provided step-by-step instructions for flushing DNS, resetting Winsock, and manually setting DNS servers (Google DNS 8.8.8.8 / 8.8.4.4).
Shared PowerShell and CMD commands to restart and reset network configurations.
What I Changed Afterwards:
Checked VM network adapters; saw NAT (10.0.2.15) and Internal Network (192.168.99.10).
Tested ping to 8.8.8.8 → successful, confirmed connectivity.
Ran network troubleshooting commands in PowerShell (ipconfig /flushdns, netsh winsock reset).
Set DNS manually in IPv4 settings to 8.8.8.8 / 8.8.4.4.
Disabled Internal Network adapter to avoid conflicts.






AI Log 12
Tool Used: Gemini 
What it Generated:
Identified a PowerShell execution policy restriction preventing the DSC_Computer module from loading.
Diagnosed a DeviceError indicating that the target OS (Windows 11 Education N) is incompatible with Windows Server features.
Provided troubleshooting commands for WMI repository repair and OS identification.
What you Changed Afterwards:
Modified the PowerShell execution policy across multiple scopes (Process, CurrentUser, LocalMachine) to RemoteSigned.
Attempted to pivot from Get-CimInstance to Get-WmiObject to bypass WMI class errors.




AI Log 13
Tool Used: Gemini 3 
What it Generated: * Diagnosis of a "Positional Parameter" error within the Node block of a DSC Configuration.
Correction of variable scoping from $AllNodes (entire collection) to $Node (current instance).
Revised DnsClient resource block to ensure correct syntax and prevent "leaking" arguments into the Node command.
What you Changed Afterwards: I updated the StudentConfig.ps1 file to replace all global $AllNodes property references with $Node references and ensured every DSC resource (like DnsClient) had a unique name string (e.g., DisableNatRegistration) to prevent compilation "choke" points.




AI Log 14
Tool Used: Gemini 
What it Generated:
Updated AllNodes.psd1 structure to include the Sites and Groups parent OUs to resolve dependency errors.
Revised StudentConfig.ps1 to satisfy the mandatory DomainName property for the ADUser resource.
Syntax corrections for the ADGroupMember resource block to fix "Positional Parameter" compiler errors.
Troubleshooting logic to address GroupScope validation failures.
What I Changed Afterwards:
Standardized variable scoping by switching from $AllNodes to $Node inside the configuration loops for better reliability.
Removed the redundant MembersToInclude property from the ADGroup resource to eliminate a conflict with the ADGroupMember wiring logic.






AI Log 15
Gemini
What it Generated: * Transcribed PowerShell hashtables for PasswordPolicy, GroupPolicies, GPOLinks, GPORegistryValues, and GPOPermissions.
Generated PowerShell DSC resource blocks for ADDomainDefaultPasswordPolicy, GroupPolicy creation loops, and GPLink assignment. What I Changed Afterwards:
Consolidated the fragmented code snippets into a single, cohesive script structure.
Verified subexpression syntax $($variable.Property) in the foreach loops to ensure dynamic resource naming.






AI Log 16
Tool Used: Gemini 
What it Generated:
Transcribed and corrected PowerShell hashtables for PasswordPolicy, OrganizationalUnits, SecurityGroups, and ADUsers based on your error logs.
A complete, syntax-corrected version of AllNodes.psd1 that removes illegal variable logic.
A consolidated StudentConfig.ps1 DSC script featuring resource blocks for ADOrganizationalUnit, ADGroup, ADUser, and ADDomainDefaultPasswordPolicy.
What I Changed Afterwards:
Fixed the specific typo Descrption to Description within the ADUser resource block.
Appended the necessary closing braces (}) to resolve the "Missing closing brace" parser errors.
Standardized the file paths to match your repository structure for compilation.