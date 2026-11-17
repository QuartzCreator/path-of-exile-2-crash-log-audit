<#
.SYNOPSIS
    PoE 2 Crash & Shader Audit — Read-Only Windows Diagnostic Script
.DESCRIPTION
    Performs non-invasive, read-only local checks on Windows (Steam paths, folder layout,
    file timestamps/sizes, and system info). Does NOT modify, delete, or upload any files,
    and does NOT require administrator privileges or changes to Windows Defender.
.NOTES
    License: MIT
#>

$ErrorActionPreference = 'SilentlyContinue'

function Get-SteamLibraries {
    $libs = @()
    $regPath = 'HKCU:\Software\Valve\Steam'
    $steamPath = (Get-ItemProperty -Path $regPath -Name 'SteamPath').SteamPath
    if (-not $steamPath) {
        $steamPath = 'C:\Program Files (x86)\Steam'
    }
    $steamPath = $steamPath -replace '/', '\'
    if (Test-Path $steamPath) {
        $libs += $steamPath
        $vdf = Join-Path $steamPath 'steamapps\libraryfolders.vdf'
        if (Test-Path $vdf) {
            $content = Get-Content -Path $vdf -Raw
            $matches = [regex]::Matches($content, '"path"\s+"([^"]+)"')
            foreach ($m in $matches) {
                $p = $m.Groups[1].Value -replace '\\', '\'
                if ((Test-Path $p) -and ($libs -notcontains $p)) {
                    $libs += $p
                }
            }
        }
    }
    return $libs
}

function Find-SteamGameDir {
    param([string[]]$FolderNames)
    foreach ($lib in (Get-SteamLibraries)) {
        foreach ($name in $FolderNames) {
            $candidate = Join-Path $lib "steamapps\common\$name"
            if (Test-Path $candidate) {
                return $candidate
            }
        }
    }
    return $null
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " PoE 2 Crash & Shader Audit (Read-Only Check)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

$docs = [Environment]::GetFolderPath('MyDocuments')
$poeDocs = Join-Path $docs "My Games\Path of Exile 2"
Write-Host "[My Games Configuration & Shader Cache]" -ForegroundColor Yellow
Write-Host "  Docs Path : $poeDocs"
if (Test-Path $poeDocs) {
    $cfg = Join-Path $poeDocs "poe2_production_Config.ini"
    if (Test-Path $cfg) {
        Write-Host "  Config    : Found ($cfg)" -ForegroundColor Green
        $renderer = Select-String -Path $cfg -Pattern "^renderer_type="
        if ($renderer) { Write-Host "  Renderer  : $($renderer.Line)" -ForegroundColor Cyan }
    }
    Get-ChildItem -Path $poeDocs -Directory -Filter "ShaderCache*" | ForEach-Object {
        $count = (Get-ChildItem -Path $_.FullName -File -Recurse).Count
        Write-Host "  Cache Dir : $($_.Name) ($count cached files)"
    }
} else {
    Write-Host "  My Games\Path of Exile 2 folder not found." -ForegroundColor DarkYellow
}
Write-Host ""

$gameDir = Find-SteamGameDir -FolderNames @("Path of Exile 2")
Write-Host "[Steam Install & Client.txt Log Check]" -ForegroundColor Yellow
if ($gameDir) {
    Write-Host "  Install   : $gameDir" -ForegroundColor Green
    $clientLog = Join-Path $gameDir "logs\Client.txt"
    if (Test-Path $clientLog) {
        $kb = [math]::Round((Get-Item $clientLog).Length / 1KB, 2)
        Write-Host "  Client.txt: Found ($kb KB)" -ForegroundColor Green
        $errors = Select-String -Path $clientLog -Pattern "ERROR|Exception|DEVICE_REMOVED|Failed" | Select-Object -Last 6
        if ($errors) {
            Write-Host "  Recent error/warning lines:" -ForegroundColor Red
            foreach ($e in $errors) { Write-Host "    Line $($e.LineNumber): $($e.Line.Trim())" }
        }
    }
} else {
    Write-Host "  Game folder not found in default Steam libraries." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "Diagnostic complete. No files were modified." -ForegroundColor Green
Read-Host "Press Enter to exit"
