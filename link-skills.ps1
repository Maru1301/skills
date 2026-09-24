param(
    [ValidateSet('Agents', 'Codex', 'Both')]
    [string]$Target = 'Agents',

    [string[]]$Skill,

    [string]$Destination,

    [switch]$Migrate,

    [switch]$List
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$skillsRoot = Join-Path $PSScriptRoot 'skills'
$available = @(Get-ChildItem -LiteralPath $skillsRoot -Directory | Where-Object {
    Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf
} | Sort-Object Name)

if ($List) {
    $available | ForEach-Object { Write-Output $_.Name }
    return
}

if ($Destination -and $Target -ne 'Agents') {
    throw 'Use -Destination by itself, or use -Target without -Destination.'
}

if ($Skill) {
    $selected = @()
    foreach ($name in $Skill) {
        $found = @($available | Where-Object { $_.Name -ceq $name })
        if ($found.Count -ne 1) {
            throw "Unknown skill '$name'. Run .\install.ps1 -List to see available skills."
        }
        $selected += $found[0]
    }
    $selected = @($selected | Sort-Object FullName -Unique)
} else {
    $selected = $available
}

if ($selected.Count -eq 0) {
    throw 'No skill folders containing SKILL.md were found in the skills directory.'
}

$destinations = @()
if ($Destination) {
    $destinations += $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)
} else {
    if ($Target -eq 'Agents' -or $Target -eq 'Both') {
        $destinations += (Join-Path $HOME '.agents/skills')
    }
    if ($Target -eq 'Codex' -or $Target -eq 'Both') {
        $codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
        $destinations += (Join-Path $codexHome 'skills')
    }
}

foreach ($root in ($destinations | Select-Object -Unique)) {
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    $rootPath = [System.IO.Path]::GetFullPath($root).TrimEnd('\')
    foreach ($source in $selected) {
        $sourcePath = [System.IO.Path]::GetFullPath($source.FullName).TrimEnd('\')
        $linkPath = [System.IO.Path]::GetFullPath((Join-Path $rootPath $source.Name)).TrimEnd('\')
        if (-not [System.IO.Path]::GetDirectoryName($linkPath).Equals($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Link path is outside its destination: $linkPath"
        }
        if ($linkPath.Equals($sourcePath, [System.StringComparison]::OrdinalIgnoreCase) -or
            $linkPath.StartsWith($sourcePath + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Cannot create a junction inside its own source: $linkPath"
        }

        $existing = Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue
        if ($existing) {
            if ($existing.LinkType -eq 'Junction') {
                $existingTarget = [System.IO.Path]::GetFullPath([string](@($existing.Target)[0])).TrimEnd('\')
                if ($existingTarget.Equals($sourcePath, [System.StringComparison]::OrdinalIgnoreCase)) {
                    Write-Output "Already linked $($source.Name) -> $sourcePath"
                } else {
                    Write-Warning "Different junction already exists: $linkPath -> $existingTarget"
                }
                continue
            }
            if ($existing.LinkType -or -not $existing.PSIsContainer) {
                Write-Warning "Different item already exists: $linkPath"
                continue
            }
            if (-not $Migrate) {
                Write-Warning "Directory already exists: $linkPath (use -Migrate to back it up and create a junction)"
                continue
            }
        }

        $backup = $null
        try {
            if ($existing) {
                $backup = [System.IO.Path]::GetFullPath((Join-Path $rootPath ('.' + $source.Name + '.backup-' + (Get-Date -Format 'yyyyMMddHHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8))))
                if (-not [System.IO.Path]::GetDirectoryName($backup).Equals($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
                    throw "Backup path is outside its destination: $backup"
                }
                Move-Item -LiteralPath $linkPath -Destination $backup
            }
            New-Item -ItemType Junction -Path $linkPath -Target $sourcePath | Out-Null
            if ($backup) {
                Write-Output "Linked $($source.Name) -> $sourcePath (previous directory: $backup)"
            } else {
                Write-Output "Linked $($source.Name) -> $sourcePath"
            }
        } catch {
            if ($backup -and (Test-Path -LiteralPath $backup) -and -not (Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue)) {
                Move-Item -LiteralPath $backup -Destination $linkPath
            }
            throw
        }
    }
}
