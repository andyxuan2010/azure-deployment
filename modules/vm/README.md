## TEST7

# switch between subscription


az vm extension image list --location canadacentral -otsv


### check the vm extension images and version
```
az vm extension image list --location canadacentral -otsv
az vm extension image list --query "[].name" --output tsv

```



## for joining the domain, we need to add the JsonADDomainExtension, the password has to use single quote instead of double quote for special characters.
```
$env:TF_VAR_domain_join_pass='Your account password here'
```
The username has to be account and at the format of:
```
domain\\\\domain_user
```


Set TF_PLUGIN_CACHE_DIR locally to improve the terraform performance

[System.Environment]::SetEnvironmentVariable("TF_DATA_DIR"
, "C:\terraform-cache", "User")
[System.Environment]::SetEnvironmentVariable("TF_PLUGIN_CACHE_DIR", "C:\terraform-cache", "User")

[todo]
Storage account change:
"Allow Blob anonymous access" must be enabled for the init.ps1 script to be accessible for VM
This could be a security issue we need to address later.



This Repo features:
 Create a dedicate application resource group
 Assign dedicated application AD group to the reader role for this RG IAM
Add 1 dedicated application AD group and CCoE Admin to local admin group of the VM
Add 1 dedicated application AD group and CCoE Admin to local remote desktop group of the VM


here is a summary of what the init.ps1 script does:

1. **Initialization**:
   - Defines parameters for log file path, remote group, and admin group.
   - Converts comma-separated strings into arrays for remote and admin groups.
   - Defines a function `Write-Log` to log messages with timestamps.

2. **Logging**:
   - Logs the start of the script.

3. **Network Configuration**:
   - Enables ICMPv4 (ping) through the firewall.

4. **PowerShell Installation**:
   - Installs PowerShell 7.5 silently and logs the process.

5. **Azure CLI Installation**:
   - Downloads and installs the Azure CLI silently and logs the process.

6. **AWS CLI Installation**:
   - Downloads and installs the AWS CLI silently and logs the process.

7. **Chocolatey Installation**:
   - Installs Chocolatey and logs the process.

8. **Package Installation via Chocolatey**:
   - Installs various packages (e.g., Kubernetes CLI, Docker CLI, SQLCMD, etc.) using Chocolatey and logs the process.

9. **Environment Variable Configuration**:
   - Sets environment variables for various installed tools.

10. **Azure Login with Identity**:
    - Logs into Azure using managed identity and logs the process.

11. **IIS Installation**:
    - Installs IIS, creates a folder if it doesn't exist, downloads a PNG file, and logs the process.

12. **OpenSSH Server Installation**:
    - Installs OpenSSH Server, configures it, sets up firewall rules, downloads an SSH key from Azure Key Vault, and logs the process.

13. **BGInfo Installation**:
    - Downloads and configures BGInfo, creates a shortcut in the Startup folder, and logs the process.

14. **PowerShell Modules Installation**:
    - Installs NuGet package provider, sets up trusted installation policy, and logs the process.

15. **Scheduled Task Script**:
    - Downloads and registers a scheduled task script to run at logon and logs the process.

16. **Azure Arc Setup Removal**:
    - Disables Azure Arc Setup in Server Manager and Settings, removes Azure Arc-related Windows features, and logs the process.

17. **WinRM Configuration**:
    - Enables and configures WinRM for remote management and logs the process.

18. **.NET Framework Installation**:
    - Downloads and installs .NET Framework 4.8 and 4.7.2 Developer Packs, verifies the installation, and logs the process.

19. **Local Group Configuration**:
    - Adds specified domain groups to local Administrators and Remote Desktop Users groups and logs the process.

20. **Script Completion**:
    - Logs the end of the script and initiates a system reboot.

This script is designed to automate the setup and configuration of a Windows environment, including installing necessary tools, configuring network settings, and setting up remote management capabilities.



dev branch is corresponding to the non-prod environment.
main branch is corresponding to the prod environment.

sql managed instance needs to add users AD group
1. in the MI login table, add user AD group
2. map to the MI DB with db owner role.



For production environment only, the backend storage account will have the Locks which is Auto-created by Azure Backup for storage accounts registered with a Recovery Services Vault. This lock is intended to guard against deletion of backups due to accidental deletion of the storage account. We need to remove this lock for terraform to work properly.

