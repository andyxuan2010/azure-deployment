# this is the cloud init script
# first run init.ps1, then  scheduled.ps1


param(
    [string]$AppEnv="sbx",
    [string]$LogFile = "$env:TEMP\InitLog.txt",
    [string]$AppRemoteGroup,
    [string]$AppAdminGroup
)

# Convert comma-separated strings into arrays
$AppRemoteGroupArray = $AppRemoteGroup -split ","
$AppAdminGroupArray = $AppAdminGroup -split ","

# Function to log messages
Function Write-Log {
    param([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -FilePath $LogFile -Append
}


Write-Log "=====================Init Script Starts========================"


Write-Log "=====================Current Environment is ${AppEnv}========================"
#enable ping
try {
    New-NetFirewallRule -DisplayName 'Allow ICMPv4-In2' -Protocol ICMPv4 -Enabled True -Action Allow | Out-File -Append -FilePath $LogFile
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "Failed to create firewall rule for ICMPv4"
}

Get-Disk | Where-Object PartitionStyle -eq 'RAW' | Initialize-Disk -PartitionStyle GPT -PassThru |
New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataDisk" -Confirm:$false




# install powershell 7.5 silently
try {

    Write-Log "-------------------powershell 7.5 install starts-----------------------"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet" | Out-File -Append -FilePath $LogFile
    New-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\powershell.exe" -Value "C:\Program Files\PowerShell\7\pwsh.exe" -Force | Out-File -Append -FilePath $LogFile
    Write-Log "-------------------powershell 7.5 install ends-----------------------"

}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "install powershell7.5 failed"
    Exit 1  # Ensure script exits with an error
}

try {
    Write-Log "-------------------AzureCLI install starts-----------------------"
    # Download the Azure CLI MSI installer
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile .\AzureCLI.msi -ErrorAction Stop | Out-File -Append -FilePath $LogFile
    # Install Azure CLI silently
    Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet /qn /norestart' -ErrorAction Stop
    Remove-Item .\AzureCLI.msi | Out-File -Append -FilePath $LogFile
    Write-Log "-------------------AzureCLI install ends-----------------------"

}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "install azure cli failed"
    Exit 1  # Ensure script exits with an error
}

try {
    Write-Log "-------------------AWS CLI starts-----------------------"
    # Define the URL for the AWS CLI MSI installer
    $awsCliUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"

    # Define the path where the MSI will be downloaded
    $downloadPath = "$env:TEMP\AWSCLIV2.msi"

    # Download the AWS CLI MSI installer
    Invoke-WebRequest -Uri $awsCliUrl -OutFile $downloadPath

    # Install AWS CLI silently
    Start-Process msiexec.exe -ArgumentList "/i `"$downloadPath`" /quiet" -Wait
    # Verify the installation
    #aws --version

    # Clean up the downloaded MSI file
    Remove-Item -Path $downloadPath -Force
    Write-Log "-------------------AWS CLI ends-----------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "install aws cli failed"
    Exit 1  # Ensure script exits with an error
}



try {
    Write-Log "-----------------choco package tools install starts-------------------------"
    # Set Execution Policy
    Set-ExecutionPolicy Bypass -Scope Process -Force
    # Ensure TLS 1.2 is enabled for secure downloads
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    # Install Chocolatey
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) -ErrorAction Stop
    Write-Log "-----------------choco package tools install ends-------------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "install choco and tools failed"
    Exit 1  # Ensure script exits with an error
}





try {
    Write-Log "--------------------install packages by choco starts----------------------"
    choco install -y --force kubernetes-helm kubernetes-cli docker-cli azcopy10 docker-compose ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force sqlcmd pgadmin4 ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force 7zip ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    #choco install -y --force awscli ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force mremoteng ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force curl jq wget putty ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force sysinternals --params "/InstallDir:C:\windows\system32" --version=2025.2.13 ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    #choco install -y --force sysinternals --version=2025.2.13 ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force vscode git gh terraform ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force mobaxterm notepadplusplus ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
	choco install -y --force azure-functions-core-tools bicep azure-kubelogin microsoftazurestorageexplorer ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    #choco install -y --force openssl | Out-File -Append -FilePath $LogFile
    #choco install -y --force azure-data-studio powerbi --ignore-checksums ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    #choco install -y --force sql-server-management-studio --limit-output --no-progress | Out-File -Append -FilePath $LogFile
    Write-Log "--------------------install packages by choco ends----------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "install packages by choco failed"
    #Exit 1  # Ensure script exits with an error
    # choco has a throttle limit, so we will ignore the error and continue.
}

#[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\ProgramData\chocolatey\bin", [System.EnvironmentVariableTarget]::Machine)
#[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\ProgramData\chocolatey\lib\sysinternals\tools", [System.EnvironmentVariableTarget]::Machine)
#[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Amazon\AWSCLIV2\", [System.EnvironmentVariableTarget]::Machine)
#[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\", [System.EnvironmentVariableTarget]::Machine)
#[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\PowerShell\7\", [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program files\sqlcmd\", [System.EnvironmentVariableTarget]::Machine)

$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

try {
    Write-Log "-------------------Az login with managed identity starts-----------------------"
    az login --identity | Out-File -Append -FilePath $LogFile
    az account show | Out-File -Append -FilePath $LogFile
    Write-Log "-------------------Az login with managed identity ends-----------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "Az login with managed identity failed"
    Exit 1  # Ensure script exits with an error
}



try {

    Write-Log "-------------------IIS install starts-----------------------"
    # Install IIS
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools | Out-File -FilePath $LogFile -Append

    # Optional: Create a simple HTML page for testing
    #Set-Content -Path "C:\\inetpub\\wwwroot\\iisstart.html" -Value "<html><body><h1>Hello from IIS!</h1></body></html>"
    # optional: add customized png
    $FolderPath = "C:\inetpub\wwwroot"

    # Check if the folder exists, and create it if it doesn't
    if (-not (Test-Path -Path $FolderPath)) {
        Write-Log "Folder does not exist. Creating folder: $FolderPath"
        New-Item -Path $FolderPath -ItemType Directory
    } else {
        Write-Log "Folder already exists: $FolderPath"
    }
    Invoke-WebRequest -Uri https://stccoeiaccc${AppEnv}.blob.core.windows.net/scripts/abc.png -OutFile c:\inetpub\wwwroot\iisstart.png | Out-File -Append -FilePath $LogFile
    Write-Log "-------------------IIS install ends-----------------------"

}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "Install IIS failed"
    Exit 1  # Ensure script exits with an error
}


try {
    Write-Log "--------------------Install OpenSSH Server starts----------------------"
    $env:TEMP = "C:\Temp"
    $env:TMP = "C:\Temp"
    #DISM /Online /Add-Capability /CapabilityName:OpenSSH.Server~~~~0.0.1.0 | Out-File -Append -FilePath $LogFile
    # Install the OpenSSH Server feature
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 | Out-File -Append -FilePath $LogFile

    # Start OpenSSH Server service
    Start-Service -Name sshd
    # Enable service to start automatically
    Set-Service -Name sshd -StartupType Automatic

    New-NetFirewallRule -Name "OpenSSH-Server" -DisplayName "OpenSSH Server (Port 22)" `
        -Enabled True -Direction Inbound -Protocol TCP `
        -Action Allow -LocalPort 22
    $vaultName = "kv-ccoe-cc-${AppEnv}"
    $secretName = "azureadmin-pubkey"
    $authorizedKeysPath = "C:\ProgramData\ssh\administrators_authorized_keys"
    # Download the public key from Key Vault
    $sshKey = az keyvault secret show --vault-name $vaultName --name $secretName --query "value" -o tsv
    # Save the SSH public key to authorized_keys
    $sshKey | Out-File -FilePath $authorizedKeysPath -Encoding ascii -Force
    # Set proper permissions
    icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r /grant:r "Administrators:F" /grant:r "SYSTEM:F"
    icacls C:\ProgramData\ssh\administrators_authorized_keys /remove "NT AUTHORITY\Authenticated Users"
    Write-Log "--------------------Install OpenSSH Server ends----------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "Install OpenSSH Server failed"
    Exit 1  # Ensure script exits with an error
}

try {
    Write-Log "--------------------install bgi starts----------------------"

    # install bgi
    # Define paths
    $bginfoPath = "C:\windows\system32\Bginfo.exe"
    $configPath = "C:\windows\default.bgi"
    $startupFolder = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup"
    $shortcutPath = Join-Path -Path $startupFolder -ChildPath "BGInfo.lnk"

    # install bgi
    Invoke-WebRequest -Uri https://stccoeiaccc${AppEnv}.blob.core.windows.net/scripts/default.bgi -OutFile $configPath | Out-File -Append -FilePath $LogFile
	#bginfo.exe C:\windows\default.bgi /timer:0 /silent /nolicprompt | Out-File -Append -FilePath $LogFile


    # Create WScript.Shell COM object
    $wshShell = New-Object -ComObject WScript.Shell

    # Create a new shortcut
    $shortcut = $wshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $bginfoPath
    $shortcut.Arguments = "`"$configPath`" /timer:0 /silent /nolicprompt"
    $shortcut.WorkingDirectory = "C:\windows"
    $shortcut.IconLocation = "$bginfoPath, 0"
    $shortcut.Save()

    Write-Log "BGInfo shortcut created in the Startup folder for all users."
    Write-Log "--------------------install bgi ends----------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "install bgi failed"
    Exit 1  # Ensure script exits with an error
}

try {
    Write-Log "--------------------install extra powershell modules starts----------------------"
    Write-Log "NuGet package is being installed."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
    Import-PackageProvider -Name NuGet -Force
    Write-Log "setup trusted installation policy."
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    $ConfirmPreference = 'None'
	Write-Log "NuGet package is installed."
    # also install the az module for powershell for everyone
    #Install-Module -Name NuGet -Scope AllUsers -Force -Verbose | Out-File -Append -FilePath $LogFile
    # Install-Module -Name Az,AWS.Tools.ec2 -Scope AllUsers -Force -Verbose | Out-File -Append -FilePath $LogFile
    # Install-Module -Name SqlServer,DBATools -Scope AllUsers -Force -Verbose | Out-File -Append -FilePath $LogFile
    # Install-Module -Name PowerShellGet -Scope AllUsers -Force -Verbose | Out-File -Append -FilePath $LogFile
    # Install-Module -Name Az.Monitor,AWS.Tools.CloudWatch -Scope AllUsers -Force -Verbose | Out-File -Append -FilePath $LogFile
    # Install-Module -Name PSReadLine,PSFramework -Scope AllUsers -Force -Verbose | Out-File -Append -FilePath $LogFile
    # Install-Module -Name Az.Security,AWS.Tools.IdentityManagement -Scope AllUsers -Force -Verbose | Out-File -Append -FilePath $LogFile
    # Install-Module -Name Az.Network -Scope AllUsers -Force -Verbose | Out-File -Append -FilePath $LogFile
    #Import-Module SqlServer
    Write-Log "--------------------install extra powershell modules ends----------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "install extra powershell modules failed"
    #Exit 1  # Ensure script exits with an error
}



try {
    Write-Log "-------------------scheduled task script starts-----------------------"
    #download scheduled task script and run it
    Invoke-WebRequest -Uri https://stccoeiaccc${AppEnv}.blob.core.windows.net/scripts/scheduled.ps1 -OutFile c:\temp\scheduled.ps1 | Out-File -Append -FilePath $LogFile
    Unblock-File -Path "C:\temp\scheduled.ps1"
    #$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"C:\temp\scheduled.ps1`""
    #$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File `""C:\temp\scheduled.ps1`""
    #$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File `"`"C:\temp\scheduled.ps1`"`""
    #$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File `"C:\temp\scheduled.ps1`""
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File C:\temp\scheduled.ps1"

    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    #Start-Sleep -Seconds 30
    #$Principal = New-ScheduledTaskPrincipal -UserId "INTERACTIVE" -LogonType Interactive -RunLevel Highest
    $Principal = New-ScheduledTaskPrincipal -UserId "azureadmin" -LogonType Interactive -RunLevel Highest
    Register-ScheduledTask -TaskName "RunAppxInstall" -Action $Action -Trigger $Trigger -Principal $Principal -Force
    Write-Log "-------------------scheduled task script ends-----------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "scheduled task script failed"
    Exit 1  # Ensure script exits with an error
}

try {
    Write-Log "---------------------remove Azure Arc Setup starts---------------------"
    # Disable Azure Arc Setup in Server Manager and Settings
    $serverManagerConfigPath = "HKLM:\SOFTWARE\Microsoft\ServerManager"
    $settingsConfigPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

    if (Test-Path $serverManagerConfigPath) {
        Set-ItemProperty -Path $serverManagerConfigPath -Name "DoNotPopulateAzureArcTiles" -Value 1
    }

    if (Test-Path $settingsConfigPath) {
        Set-ItemProperty -Path $settingsConfigPath -Name "DisableAzureArcSetup" -Value 1
    }

    # Remove Azure Arc-related Windows features
    $azureArcFeatures = Get-WindowsFeature | Where-Object { $_.Name -like "*Azure*Arc*" }
    if ($azureArcFeatures) {
        $azureArcFeatures | ForEach-Object {
            Remove-WindowsFeature -Name $_.Name -Confirm:$false
        }
    }
    # Define the path to the shortcut
    $shortcutPath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Azure Arc Setup.lnk"
    # Check if the shortcut exists
    if (Test-Path $shortcutPath) {
        takeown /F $shortcutPath
        icacls $shortcutPath /reset
        # Remove the shortcut
        Remove-Item -Path $shortcutPath -Force
        Write-Log "The Azure Arc Setup shortcut has been removed."
    } else {
        Write-Log "The Azure Arc Setup shortcut does not exist."
    }
    Write-Log "---------------------remove Azure Arc Setup ends---------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "remove Azure Arc Setup failed"
    Exit 1  # Ensure script exits with an error
}


try {
    Write-Log "--------------------Enable WinRM starts----------------------"
    # Enable WinRM
    winrm quickconfig -quiet
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    Write-Log "--------------------Enable WinRM ends----------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "Enable WinRM failed"
    Exit 1  # Ensure script exits with an error
}


try {
    Write-Log "---------------------Install .net framework 4.8 developer pack starts---------------------"
    $installerUrl = "https://go.microsoft.com/fwlink/?linkid=2088517"
    $installerPath = "C:\temp\ndp48-devpack.exe"

    # Download the installer
    if (-Not (Test-Path $installerPath)) {
        Write-Log "Downloading .NET Framework 4.8 Developer Pack..."
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
    }

    # Check if the installer exists
    if (-Not (Test-Path $installerPath)) {
        Write-Log "Installer not found at $installerPath. Download failed."
        exit 1
    }
    # Run the installer silently
    Write-Log "Installing .NET Framework 4.8 Developer Pack..."
    Start-Process -FilePath $installerPath -ArgumentList "/q /norestart" -Wait

    # Verify the installation
    $net48Path = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
    if (Test-Path $net48Path) {
        $releaseKey = Get-ItemProperty $net48Path -Name Release
        if ($releaseKey.Release -ge 528040) { # 528040 is the release key for .NET Framework 4.8
            Write-Log ".NET Framework 4.8 Developer Pack installed successfully."
        } else {
            Write-Log ".NET Framework 4.8 Developer Pack installation failed or an older version is installed."
            exit 1
        }
    } else {
        Write-Log ".NET Framework 4.8 Developer Pack installation failed."
    }
    Write-Log "---------------------Install .net framework 4.8 developer pack ends---------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "Install .net framework 4.8 developer pack failed"
    Exit 1  # Ensure script exits with an error
}


try {
    Write-Log "----------------------Install .net framework 4.7.2 developer pack starts--------------------"
    $installerUrl = "https://go.microsoft.com/fwlink/?linkid=874338"
    $installerPath = "C:\temp\ndp472-devpack.exe"

    # Download the installer
    if (-Not (Test-Path $installerPath)) {
        Write-Log "Downloading .NET Framework 4.7.2 Developer Pack..."
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
    }
    # Check if the installer exists
    if (-Not (Test-Path $installerPath)) {
        Write-Log "Installer not found at $installerPath. Download failed."
        exit 1
    }
    # Run the installer silently
    Write-Log "Installing .NET Framework 4.7.2 Developer Pack..."
    Start-Process -FilePath $installerPath -ArgumentList "/q /norestart" -Wait

    # Verify the installation
    $net472Path = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
    if (Test-Path $net472Path) {
        $releaseKey = Get-ItemProperty $net48Path -Name Release
        if ($releaseKey.Release -ge 461808) { # 461808 is the release key for .NET Framework 4.7.2
            Write-Log ".NET Framework 4.7.2 Developer Pack installed successfully."
        } else {
            Write-Log ".NET Framework 4.7.2 Developer Pack installation failed or an older version is installed."
            exit 1
        }
    } else {
        Write-Log ".NET Framework 4.7.2 Developer Pack installation failed."
    }
    Write-Log "----------------------Install .net framework 4.7.2 developer pack ends--------------------"

}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "Install .net framework 4.7.2 developer pack failed"
    Exit 1  # Ensure script exits with an error
}

try {
    Write-Log "--------------------Add users to the local group starts----------------------"

    # Add domain group to local Administrators
    foreach ($member in $AppAdminGroupArray) {
        Write-Log "Added $AppAdminGroup to Administrators group and added $AppRemoteGroup to RemoteDesktopUsers Group"
        Add-LocalGroupMember -Group "Administrators" -Member $member -ErrorAction SilentlyContinue | Out-File -Append -FilePath $LogFile
    }

    # Add domain group to Remote Desktop Users
    foreach ($member in $AppRemoteGroupArray) {
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member $member -ErrorAction SilentlyContinue | Out-File -Append -FilePath $LogFile
    }

    Write-Log "Added $AppAdminGroup to Administrators group and added $AppRemoteGroup to RemoteDesktopUsers Group"

    Write-Log "--------------------Add users to the local group ends----------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "Enable WinRM failed"
    Exit 1  # Ensure script exits with an error
}


#Write-Log "Init Script ended and rebooting will be done through domain join extension"
Write-Log "Init Script ended and rebooting ..."
shutdown -r -t 0 -f
Write-Log "=====================Init Script Ends========================"



# Write-Log "Run the second script..."
# & "$PSScriptRoot\createdbuser.ps1"