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
function Get-Hypervisor {
    try {
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem
        $bios = Get-CimInstance -ClassName Win32_BIOS
        $man = ($cs.Manufacturer, $cs.Model, $bios.Manufacturer, $bios.SMBIOSBIOSVersion) -join ' '
        switch -Regex ($man) {
            "Xen|Citrix"         { return "Xen" }
            "KVM|QEMU|Red Hat"   { return "KVM" }
            "VMware"             { return "VMware" }
            "Microsoft|Hyper-V"  { return "HyperV" }
            default              { return "Physical" }
        }
    } catch { return "Unknown" }
}

$hv = Get-Hypervisor
echo $hv > C:\Windows\Temp\virtio-hv.log
$virtioPath = "D:\Drivers\Proxmox\Windows11\virtio-win-guest-tools.exe"
if ($hv -eq "KVM" -and (Test-Path $virtioPath)) {
   echo "install KVM drivers" >> C:\Windows\Temp\virtio-hv.log
   pnputil /add-driver "C:\Drivers\Proxmox\Virtio\*.inf" /install /subdirs /force
   #D:\Drivers\Proxmox\Windows11\virtio-win-guest-tools.exe /S
   #Start-Process -FilePath $virtioPath -ArgumentList '/S /norestart /log="C:\Windows\Temp\virtio-install.log"' 
   #Start-Sleep -Seconds 20
}



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
#while ($true) {
#    $connectionTest = Test-NetConnection -ComputerName 8.8.8.8 -Port 443
#    if ($connectionTest.TcpTestSucceeded) {
#        Write-Host "Network connection detected!"
#        break
#    } else {
#        Write-Host "No network connection. Retrying in 5 seconds..."
#        Start-Sleep -Seconds 5
#    }
#}
Start-Sleep -Seconds 10

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Script Start-SplashScreen -Force | Out-Null

Start-SplashScreen.ps1 -Processes $Scripts2run
