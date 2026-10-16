param([string]$GameRoot)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Common.ps1')
$gameRoot = Get-ProjectUnknownGameRoot -RequestedPath $GameRoot
$pakTarget = Join-Path $gameRoot 'ProjectUnknown\Content\Paks\ProjectUnknown-Windows_P.pak'
$pakBackup = "$pakTarget.before-ProjectUnknownMaisJogadores.bak"
$statePath = Join-Path $env:LOCALAPPDATA 'ProjectUnknownMaisJogadores\InstalledPak.sha256'
$knownModHashes = @(
    '0C3D22B80BD6B5C223C067119CD6886990D3B800EC50C967F4EDA883FB1F2378',
    '9AC430CC47529DF0B17B42F95B2011FDA03164D86ED3609C1A8FF95FC4DDDC4C'
)
if (Test-Path -LiteralPath $statePath) {
    $knownModHashes += [System.IO.File]::ReadAllText($statePath).Trim()
}

if (Test-Path -LiteralPath $pakTarget) {
    $targetHash = (Get-FileHash -LiteralPath $pakTarget -Algorithm SHA256).Hash
    if (Test-Path -LiteralPath $pakBackup) {
        if ($knownModHashes -contains $targetHash) {
            Copy-Item -LiteralPath $pakBackup -Destination $pakTarget -Force
            Remove-Item -LiteralPath $pakBackup -Force
            Write-Host 'PAK anterior restaurado.'
        } else {
            Write-Warning "O PAK atual mudou desde a instalação. Não foi substituído; o backup está em $pakBackup"
        }
    } elseif ($knownModHashes -contains $targetHash) {
        Remove-Item -LiteralPath $pakTarget -Force
        Write-Host 'PAK do mod removido.'
    } else {
        Write-Warning 'O PAK atual não corresponde ao mod conhecido; foi mantido.'
    }
}
if (Test-Path -LiteralPath $statePath) { Remove-Item -LiteralPath $statePath -Force }

$configPath = Join-Path $env:LOCALAPPDATA 'ProjectUnknown\Saved\Config\Windows\Game.ini'
if (Test-Path -LiteralPath $configPath) {
    $text = [System.IO.File]::ReadAllText($configPath)
    $lines = [System.Collections.Generic.List[string]]::new()
    foreach ($line in ($text -split '\r?\n')) { $lines.Add($line) }
    $section = '[/Script/Engine.GameSession]'
    $start = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -ieq $section) { $start = $i; break }
    }
    if ($start -ge 0) {
        $end = $lines.Count
        for ($i = $start + 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^\s*\[.+\]\s*$') { $end = $i; break }
        }
        for ($i = $end - 1; $i -gt $start; $i--) {
            if ($lines[$i] -match '^\s*MaxPlayers\s*=') { $lines.RemoveAt($i) }
        }
        $end = $lines.Count
        for ($i = $start + 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^\s*\[.+\]\s*$') { $end = $i; break }
        }
        $hasOtherContent = $false
        for ($i = $start + 1; $i -lt $end; $i++) {
            if ($lines[$i].Trim() -ne '' -and -not $lines[$i].Trim().StartsWith(';')) {
                $hasOtherContent = $true
                break
            }
        }
        if (-not $hasOtherContent) { $lines.RemoveAt($start) }
    }
    [System.IO.File]::WriteAllText(
        $configPath,
        ($lines -join [Environment]::NewLine).TrimEnd() + [Environment]::NewLine,
        [System.Text.UTF8Encoding]::new($false)
    )
    Write-Host 'A configuração MaxPlayers foi removida. O backup original Game.ini permanece guardado.'
}
Write-Host 'Remoção concluída. Reinicie o jogo.'
