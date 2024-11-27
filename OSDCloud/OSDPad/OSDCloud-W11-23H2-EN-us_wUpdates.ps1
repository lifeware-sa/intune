<#
.SYNOPSIS
    OSDCloud Automation Script for Windows Deployment

.DESCRIPTION
    Automates the deployment of Windows 11 with specified parameters, downloads OOBE scripts, and sets up post-installation tasks.

.NOTES
    Author: Lifeware
    Version: 1.0

    Changelog:
    - 2024-10-04: 1.0 Initial version

    
#>
    
#################################################################
#   [PreOS] Update Module
#################################################################
Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
Install-Module OSD -Force -ErrorAction SilentlyContinue

Write-Host  -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force   

#################################################################
#   [OS] Params and Start-OSDCloud
#################################################################
$Params = @{
    OSVersion = "Windows 11"
    OSBuild = "23H2"
    OSEdition = "Pro"
    OSLanguage = "en-us"
    OSLicense = "Retail"
    ZTI = $true
    Firmware = $false
    SkipAutopilot = $true
}
Start-OSDCloud @Params

#################################################################
#  [PostOS] OOBE CMD Command Line
#################################################################
Write-Host -ForegroundColor Green "Downloading and creating script for OOBE phase"
New-Item -Path "C:\Windows\Setup\Scripts" -ItemType Directory -Force | Out-Null

# LW-Certificate
Copy-Item -Path "X:\OSDCloud\Config\Scripts\SetupComplete\LifewareRootCA.cer" -Destination "C:\OSDCloud\Scripts\SetupComplete\LifewareRootCA.cer" -Force
Copy-Item -Path "X:\OSDCloud\Config\Scripts\SetupComplete\SetupComplete.cmd" -Destination "C:\OSDCloud\Scripts\SetupComplete\SetupComplete.cmd" -Force
Copy-Item -Path "X:\OSDCloud\Config\Scripts\SetupComplete\SetupComplete.ps1" -Destination "C:\OSDCloud\Scripts\SetupComplete\SetupComplete.ps1" -Force

Write-Host  -ForegroundColor Green "Marvel copy driver install"
Copy-Item -Path "X:\OSDCloud\Config\Scripts\SetupComplete\marvelDriver.msi" -Destination "C:\OSDCloud\Scripts\SetupComplete\marvelDriver.msi" -Force


$OOBEScript = "Updates_Activation.ps1"
Invoke-RestMethod   -Uri "https://github.com/lifeware-sa/intune/raw/refs/heads/main/OSDCloud/OOBE/SplashScreen/$OOBEScript" `
                    -OutFile "C:\Windows\Setup\Scripts\$OOBEScript"

$OOBECMD = @"
@echo off
call :LOG > C:\Windows\Setup\Scripts\oobe.log
exit /B

:LOG

set LOCALAPPDATA=%USERPROFILE%AppDataLocal
set PSExecutionPolicyPreference=Unrestricted

certutil -addstore root C:\OSDCloud\Scripts\SetupComplete\LifewareRootCA.cer

powershell.exe -Command Get-NetIPAddress
powershell.exe -Command Set-ExecutionPolicy Unrestricted -Force

powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\Windows\Setup\Scripts\$OOBEScript"
 
"@
$OOBECMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\oobe.cmd' -Encoding ascii -Force

#################################################################
#   [PostOS] Restart-Computer
#################################################################

10..1 | ForEach-Object{
    Write-Progress -Activity "Computer Restart" -Status "in $_ seconds"
    Start-Sleep -seconds 1
 }
Restart-Computer -Force

