param(
    [ValidateRange(5, 8)][int]$MaxPlayers = 8,
    [string]$GameRoot
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$gameRoot = Get-ProjectUnknownGameRoot -RequestedPath $GameRoot
$repoRoot = Split-Path -Parent $PSScriptRoot
$pakSource = Join-Path $repoRoot 'mod\ProjectUnknown-Windows_P.pak'
if (-not (Test-Path -LiteralPath $pakSource)) { throw "PAK do mod não encontrado: $pakSource" }

$pakDir = Join-Path $gameRoot 'ProjectUnknown\Content\Paks'
$pakTarget = Join-Path $pakDir 'ProjectUnknown-Windows_P.pak'
$pakBackup = "$pakTarget.before-ProjectUnknownMaisJogadores.bak"
$stateDir = Join-Path $env:LOCALAPPDATA 'ProjectUnknownMaisJogadores'
$statePath = Join-Path $stateDir 'InstalledPak.sha256'
$knownModHashes = @(
    '0C3D22B80BD6B5C223C067119CD6886990D3B800EC50C967F4EDA883FB1F2378',
    '9AC430CC47529DF0B17B42F95B2011FDA03164D86ED3609C1A8FF95FC4DDDC4C'
)
if (Test-Path -LiteralPath $statePath) {
    $knownModHashes += [System.IO.File]::ReadAllText($statePath).Trim()
}

New-Item -ItemType Directory -Path $pakDir -Force | Out-Null
$sourceHash = (Get-FileHash -LiteralPath $pakSource -Algorithm SHA256).Hash
if (Test-Path -LiteralPath $pakTarget) {
    $targetHash = (Get-FileHash -LiteralPath $pakTarget -Algorithm SHA256).Hash
    if ($sourceHash -ne $targetHash) {
        if (($knownModHashes -notcontains $targetHash) -and -not (Test-Path -LiteralPath $pakBackup)) {
            Copy-Item -LiteralPath $pakTarget -Destination $pakBackup
            Write-Host "Backup do PAK existente criado: $pakBackup"
        }
        Copy-Item -LiteralPath $pakSource -Destination $pakTarget -Force
    }
} else {
    Copy-Item -LiteralPath $pakSource -Destination $pakTarget
}

New-Item -ItemType Directory -Path $stateDir -Force | Out-Null
[System.IO.File]::WriteAllText($statePath, $sourceHash + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))

$configDir = Join-Path $env:LOCALAPPDATA 'ProjectUnknown\Saved\Config\Windows'
$configPath = Join-Path $configDir 'Game.ini'
$configBackup = Join-Path $configDir 'Game.ini.before-ProjectUnknownMaisJogadores.bak'
New-Item -ItemType Directory -Path $configDir -Force | Out-Null
if (-not (Test-Path -LiteralPath $configPath)) {
    [System.IO.File]::WriteAllText($configPath, '', [System.Text.UTF8Encoding]::new($false))
}
if (-not (Test-Path -LiteralPath $configBackup)) {
    Copy-Item -LiteralPath $configPath -Destination $configBackup
}

$text = [System.IO.File]::ReadAllText($configPath)
$lines = [System.Collections.Generic.List[string]]::new()
foreach ($line in ($text -split '\r?\n')) { $lines.Add($line) }
if ($lines.Count -eq 1 -and $lines[0] -eq '') { $lines.Clear() }

$section = '[/Script/Engine.GameSession]'
$start = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Trim() -ieq $section) { $start = $i; break }
}
if ($start -lt 0) {
    if ($lines.Count -gt 0 -and $lines[$lines.Count - 1].Trim() -ne '') { $lines.Add('') }
    $lines.Add($section)
    $lines.Add("MaxPlayers=$MaxPlayers")
} else {
    $end = $lines.Count
    for ($i = $start + 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\s*\[.+\]\s*$') { $end = $i; break }
    }
    $found = $false
    for ($i = $start + 1; $i -lt $end; $i++) {
        if ($lines[$i] -match '^\s*MaxPlayers\s*=') {
            $lines[$i] = "MaxPlayers=$MaxPlayers"
            $found = $true
            break
        }
    }
    if (-not $found) { $lines.Insert($end, "MaxPlayers=$MaxPlayers") }
}
[System.IO.File]::WriteAllText(
    $configPath,
    ($lines -join [Environment]::NewLine).TrimEnd() + [Environment]::NewLine,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host ''
Write-Host "Mod instalado para até $MaxPlayers jogadores."
Write-Host "Jogo: $gameRoot"
Write-Host "PAK: $pakTarget"
Write-Host 'Todos os participantes precisam instalar este mod. Só o host precisa do limite configurado para criar a sala.'
Write-Host 'Feche e abra o jogo novamente antes de jogar.'
