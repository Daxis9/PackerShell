#!/usr/bin/env pwsh
# Author: Thomas Aschemann
# INSTALL PSMSI
#$body = @"{`"text`":`"Adjutant Online. Microsoft Teams version $msiversion is available.`"}"@

#$InstallerSharePath = "\\itsys-sccm.ad.siu.edu\Software$\"
#$temp = "$env:TEMP\teams"
$InstallerSharePath = "$env:USERPROFILE\Desktop"
$temp = "$env:TEMP\adobe_acrodc"
$arch = @{"32" = "x86"; "64" = "x64"}
$body = @"
    {`"text`":`"Adjutant Online. Adobe AcrobatDC version $msiversion is available.`"}
"@

if (!(Test-Path -Path "$temp")) {
    New-Item -Path "$temp" -ItemType Directory -Force
}

arch.keys | ForEach-Object { Invoke-WebRequest -Uri $("" -f $_) -OutFile $("$temp" -f $arch[$_]) }
$msiversion = Get-MSIProperty -Property ProductVersion -Path $temp | Select-Object -ExpandProperty Value

if (!(Test-Path -Path $InstallerSharePath\$msiversion)) {
    Invoke-RestMethod -Method Post -ContentType 'Application/Json' -Body $body -Uri "https://outlook.office.com/webhook/2f9ed641-7b1f-4599-a051-ac10f7936766@d57a98e7-744d-43f9-bc91-08de1ff3710d/IncomingWebhook/86d2a7b9df98433b97940e51f80fccff/0346bb91-bfa3-462c-ae57-205a05da36eb"
    foreach ($value in $arch.Values) {
        New-Item -Path "$InstallerSharePath\$msiversion\$value" -ItemType Directory -Force
        do {
            Start-Sleep -Seconds 3
            Move-Item -Path "$temp" -Destination "$InstallerSharePath\$msiversion\$value" -Force -Confirm:$false
        } while (-not $?)
    }
}