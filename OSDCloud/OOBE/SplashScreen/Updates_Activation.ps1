<#
.SYNOPSIS
    Displays a Splash Screen to Installs the latest Windows 10/11 quality updates + activates Windows. 

.NOTES
    FileName:    Updates-and-Activation.ps1
    Author:      Florian Salzmann
    Created:     2024-08-09
    Updated:     2024-08-14

    Version history:
    1.0 - (2024-08-09) Script created
    1.1 - (2024-08-14) TLS 1.2 added/forced

#>
$Scripts2run = @(
  @{
    Name = "Enabling built-in Windows Producy Key"
    Script = "https://github.com/lifeware-sa/intune/raw/refs/heads/main/OSDCloud/OOBE/Set-EmbeddedWINKey.ps1"
  },
  @{
    Name = "Windows Quality Updates"
    Script = "https://github.com/lifeware-sa/intune/raw/refs/heads/main/OSDCloud/OOBE/Windows-Updates_Quality.ps1"
  },
  @{
    Name = "Windows Firmware and Driver Updates"
    Script = "https://github.com/lifeware-sa/intune/raw/refs/heads/main/OSDCloud/OOBE/Windows-Updates_DriverFirmware.ps1"
  },
  @{
    Name = "Saving Logs and Cleanup"
    Script = "https://github.com/lifeware-sa/intune/raw/refs/heads/main/OSDCloud/OOBE/OSDCloud-CleanUp.ps1"
  }
)

Write-Host "Starting Windows Updates and Activation"

C:\OSDCloud\Scripts\SetupComplete\marvelDriver.msi /qn

# Wait for network connectivity
Write-Host "Waiting for network connectivity..."

# Loop to check for active network connection
while ($true) {
    $connectionTest = Test-NetConnection -ComputerName 8.8.8.8 -Port 443
    if ($connectionTest.TcpTestSucceeded) {
        Write-Host "Network connection detected!"
        break
    } else {
        Write-Host "No network connection. Retrying in 5 seconds..."
        Start-Sleep -Seconds 5
    }
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force | Out-Null

if($(Get-PSRepository).Name -notcontains "PSGallery") {
  [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
  Register-PSRepository -Default -Verbose
  Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}
# Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Script -Name Get-WindowsAutoPilotInfo -Force | Out-Null
Install-Module -Name WindowsAutopilotIntune -Force | Out-Null

Install-Script Start-SplashScreen -Force | Out-Null

Start-SplashScreen.ps1 -Processes $Scripts2run
