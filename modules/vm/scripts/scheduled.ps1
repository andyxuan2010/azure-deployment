# this is the scheduled powershell script
# first run init.ps1, then  scheduled.ps1

$LogFile = "c:\InitLog.txt"

# Function to log messages
Function Write-Log {
    param([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -FilePath $LogFile -Append
}

Write-Log "====================Scheduled Script Starts========================="

try {

    Write-Log "--------------------microsoft-windows-terminal starts----------------------"
    # Download the Microsoft.WindowsTerminal_1.22.10352.0_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip
    Invoke-WebRequest -Uri https://github.com/microsoft/terminal/releases/download/v1.22.10352.0/Microsoft.WindowsTerminal_1.22.10352.0_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip -OutFile c:\temp\Microsoft.WindowsTerminal.zip
    Expand-Archive -Path "c:\temp\Microsoft.WindowsTerminal.zip"  -DestinationPath "c:\temp\" -force
    #nblock-File -Path "C:\temp\Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe.appx"
    #nblock-File -Path "c:\temp\60e81fd657c844c0ba03687c799996d5.msixbundle"
    Add-AppxPackage -Path "c:\temp\Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe.appx"
    Write-Log "Add package Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe.appx"
    #DISM /Online /Add-ProvisionedAppxPackage /PackagePath:"c:\temp\Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe.appx" /SkipLicense /LogPath:$LogFile /LogLevel:4
    #Add-AppxPackage -Path "c:\temp\60e81fd657c844c0ba03687c799996d5.msixbundle" -Verbose 4>&1 | Out-File -FilePath $LogFile -Append
    DISM /Online /Add-ProvisionedAppxPackage /PackagePath:"C:\temp\60e81fd657c844c0ba03687c799996d5.msixbundle" /LicensePath:"c:\temp\60e81fd657c844c0ba03687c799996d5_License1.xml"
    Write-Log "Add package 60e81fd657c844c0ba03687c799996d5.msixbundle"



    # # Set Windows Terminal as the default terminal app
    # $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    # $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

    # # Ensure the "startOnUserLogin" and "defaultProfile" settings are configured
    # if (-not $settings.startOnUserLogin) {
    #     $settings | Add-Member -MemberType NoteProperty -Name "startOnUserLogin" -Value $true
    # }


    # # Save the updated settings
    # $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath

    # Set Windows Terminal as the default terminal app in the system
    Set-ItemProperty -Path "HKCU:\Console" -Name "DefaultTerminalApp" -Value "WindowsTerminal"
    Write-Log "--------------------microsoft-windows-terminal ends----------------------"


}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "install microsoft-windows-terminal failed"
    Exit 1  # Ensure script exits with an error
}


try {
    Write-Log "install packages by choco"
    Write-Log "------------------Install packages by choco starts------------------------"
    #choco install -y --force azure-functions-core-tools bicep azure-kubelogin microsoftazurestorageexplorer ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force azure-data-studio powerbi --ignore-checksums ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force sql-server-management-studio --limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force visualstudio2022community --package-parameters "'--quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.CoreEditor'" --limit-output --no-progress | Out-File -Append -FilePath $LogFile
    choco install -y --force self-hosted-integration-runtime ---limit-output --no-progress | Out-File -Append -FilePath $LogFile
    Write-Log "------------------Install packages by choco ends------------------------"
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "install packages by choco failed"
    #Exit 1  # Ensure script exits with an error
    # choco has a throttle limit, so we will ignore the error and continue.
}

# try {
#     Write-Log "-------------------winget install starts-----------------------"
#     # install winget
#     #$env:WinGetVer=1.8.1911
#     Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.9.25200/7fdfd40ea2dc40deab85b69983e1d873_License1.xml -outfile license.xml
#     # Download Winget, version bump update als the msixbundle file
#     Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.9.25200/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -outfile Microsoft.DesktopAppInstaller.WinGet.appx
#     # Install WingetWith License
#     Add-AppxProvisionedPackage -Online -PackagePath .\Microsoft.DesktopAppInstaller.WinGet.appx -LicensePath .\license.xml /LogPath:$LogFile /LogLevel:4
#     Write-Log "-------------------winget install ends-----------------------"
# }
# Catch {
#     Write-Log "ERROR: $_"
#     Write-Log "install bgi failed"
#     Exit 1  # Ensure script exits with an error
# }




Write-Log "-------------------Disable RunAppxInstall task-----------------------"
Disable-ScheduledTask -TaskName "RunAppxInstall" | Out-File -FilePath $LogFile -Append

Write-Log "===================Scheduled Script ended=========================="