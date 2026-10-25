# Installe SQLVault Studio (dernière version) sur Windows 10 ou 11, sans droits administrateur.
#   irm https://raw.githubusercontent.com/sqlvaultgateway/sqlvault-studio/main/install.ps1 | iex
# Désinstaller : Paramètres > Applications > SQLVault Studio > Désinstaller (vos bases sont conservées).
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'   # téléchargement bien plus rapide sans barre de progression
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$api = if ($env:SQLVAULT_STUDIO_API) { $env:SQLVAULT_STUDIO_API } else { 'https://api.github.com/repos/sqlvaultgateway/sqlvault-studio/releases/latest' }
Write-Host '==> Recherche de la dernière version...' -ForegroundColor Cyan
$release = Invoke-RestMethod -Uri $api -Headers @{ 'User-Agent' = 'sqlvault-studio-install' }
$asset = $release.assets | Where-Object { $_.name -like '*Windows-x64.exe' } | Select-Object -First 1
$sums = $release.assets | Where-Object { $_.name -eq 'SHA256SUMS.txt' } | Select-Object -First 1
if (-not $asset) { throw "Aucun installateur Windows dans la dernière version." }

$tmp = Join-Path $env:TEMP $asset.name
Write-Host "==> Téléchargement de $($asset.name)..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tmp -UseBasicParsing

if ($sums) {
  $line = (Invoke-WebRequest -Uri $sums.browser_download_url -UseBasicParsing).Content -split "`n" | Where-Object { $_ -match [regex]::Escape($asset.name) + '\s*$' }
  $expected = ($line -split '\s+')[0].ToLower()
  $actual = (Get-FileHash -Algorithm SHA256 $tmp).Hash.ToLower()
  if ($expected -ne $actual) { Remove-Item $tmp; throw "Le fichier téléchargé est altéré (empreinte SHA-256 différente)." }
  Write-Host '==> Empreinte SHA-256 vérifiée.' -ForegroundColor Cyan
}

Write-Host '==> Installation...' -ForegroundColor Cyan
Unblock-File $tmp
Start-Process -FilePath $tmp -ArgumentList '/S' -Wait
Remove-Item $tmp
Write-Host '==> SQLVault Studio est installé : menu Démarrer ou raccourci sur le Bureau.' -ForegroundColor Green
