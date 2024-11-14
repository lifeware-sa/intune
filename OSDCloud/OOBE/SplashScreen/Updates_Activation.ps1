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
# Pausing in an infinite loop to allow debugging in a separate session
Write-Host "Pausing for debugging. Open a new PowerShell window for debugging, then type 'continue' to resume the script."

# Wait for network connectivity
Write-Host "Waiting for network connectivity..."

# Loop to check for active network connection
while ($true) {
    # You can specify a common site to test connectivity, such as Google DNS (8.8.8.8)
    $connectionTest = Test-Connection -ComputerName 8.8.8.8 -Count 1 -Quiet
    if ($connectionTest) {
        Write-Host "Network connection detected!"
        break
    } else {
        Write-Host "No network connection. Retrying in 5 seconds..."
        Start-Sleep -Seconds 5
    }
}


# Infinite loop to hold the script
# while ($true) {
#     $input = Read-Host "Type 'continue' to proceed"
#     if ($input -eq 'continue') { break }
#     Write-Host "Waiting for 'continue' command..."
# }

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[Net.ServicePointManager]::SecurityProtocol 
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Script Start-SplashScreen -Force | Out-Null

Start-SplashScreen.ps1 -Processes $Scripts2run
