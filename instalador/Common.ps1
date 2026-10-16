function Test-ProjectUnknownGameRoot {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    return (Test-Path -LiteralPath (Join-Path $Path 'ProjectUnknown\Content\Paks'))
}

function Get-ProjectUnknownGameRoot {
    param([string]$RequestedPath)

    if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
        $resolved = [System.IO.Path]::GetFullPath($RequestedPath)
        if (Test-ProjectUnknownGameRoot $resolved) { return $resolved }
        throw "A pasta informada não contém ProjectUnknown\Content\Paks: $resolved"
    }

    $candidates = [System.Collections.Generic.List[string]]::new()
    $seen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $addCandidate = {
        param([string]$Value)
        if (-not [string]::IsNullOrWhiteSpace($Value)) {
            try {
                $full = [System.IO.Path]::GetFullPath($Value)
                if ($seen.Add($full)) { $candidates.Add($full) }
            } catch {}
        }
    }

    $current = $PSScriptRoot
    while (-not [string]::IsNullOrWhiteSpace($current)) {
        & $addCandidate $current
        $parent = Split-Path -Parent $current
        if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $current) { break }
        $current = $parent
    }

    $steamRoots = [System.Collections.Generic.List[string]]::new()
    foreach ($key in @(
        'HKCU:\Software\Valve\Steam',
        'HKLM:\SOFTWARE\Valve\Steam',
        'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam'
    )) {
        try {
            $props = Get-ItemProperty -LiteralPath $key
            foreach ($name in @('SteamPath', 'InstallPath')) {
                $value = $props.$name
                if (-not [string]::IsNullOrWhiteSpace([string]$value)) { $steamRoots.Add([string]$value) }
            }
        } catch {}
    }

    foreach ($value in @($env:ProgramFiles, [Environment]::GetEnvironmentVariable('ProgramFiles(x86)'), $env:ProgramW6432)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$value)) { $steamRoots.Add((Join-Path $value 'Steam')) }
    }

    $libraries = [System.Collections.Generic.List[string]]::new()
    foreach ($steamRoot in $steamRoots) {
        if (Test-Path -LiteralPath $steamRoot) { $libraries.Add($steamRoot) }
        $vdf = Join-Path $steamRoot 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $vdf) {
            try {
                $contents = [System.IO.File]::ReadAllText($vdf)
                foreach ($match in [regex]::Matches($contents, '"path"\s+"([^"]+)"')) {
                    $library = $match.Groups[1].Value.Replace('\\', '\')
                    if (-not [string]::IsNullOrWhiteSpace($library)) { $libraries.Add($library) }
                }
            } catch {}
        }
    }

    $seenLibraries = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($library in $libraries) {
        try {
            $lib = [System.IO.Path]::GetFullPath($library)
            if (-not $seenLibraries.Add($lib)) { continue }
            $steamApps = Join-Path $lib 'steamapps'
            $manifest = Join-Path $steamApps 'appmanifest_2115390.acf'
            $installDir = 'Beast Management'
            if (Test-Path -LiteralPath $manifest) {
                $manifestText = [System.IO.File]::ReadAllText($manifest)
                $m = [regex]::Match($manifestText, '"installdir"\s+"([^"]+)"')
                if ($m.Success) { $installDir = $m.Groups[1].Value }
            }
            & $addCandidate (Join-Path (Join-Path $steamApps 'common') $installDir)
            & $addCandidate (Join-Path (Join-Path $steamApps 'common') 'Beast Management')
        } catch {}
    }

    foreach ($candidate in $candidates) {
        if (Test-ProjectUnknownGameRoot $candidate) { return $candidate }
    }
    throw 'Não encontrei o jogo Project Unknown. Execute o instalador a partir do repositório extraído ou informe -GameRoot "C:\caminho\Beast Management".'
}
