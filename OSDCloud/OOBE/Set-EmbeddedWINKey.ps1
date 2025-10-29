<#
.SYNOPSIS
    Install

.NOTES
    FileName:    Windows-Updates_Quality.ps1
    Author:      Lifeware
    Created:     2024-10-04


    Version history:
        2024-10-04, 1.0:    Script created.

#>

$Global:Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-Install-EmbeddedProductKey.log"
Start-Transcript -Path (Join-Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\OSD\" $Global:Transcript) -ErrorAction Ignore

Write-Host -ForegroundColor Green "Get embedded product key"
$Key = (Get-WmiObject SoftwareLicensingService).OA3xOriginalProductKey

If ($Key) {
    Write-Host -ForegroundColor Green "Installing embedded product key"
    Invoke-Command -ScriptBlock {& 'cscript.exe' "$env:windir\system32\slmgr.vbs" '/ipk' "$($Key)"}
    Start-Sleep -Seconds 5

    Write-Host -ForegroundColor Green "Activating embedded product key"
    Invoke-Command -ScriptBlock {& 'cscript.exe' "$env:windir\system32\slmgr.vbs" '/ato'}
    Start-Sleep -Seconds 5
}

Else {
    Write-Host -ForegroundColor Red 'No embedded product key found.'
}

start c:\osdloud\scripts\setupcomplete\setupcomplete.cmd

Stop-Transcript
