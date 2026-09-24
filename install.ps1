param(
    [ValidateSet('Agents', 'Codex', 'Both')]
    [string]$Target = 'Agents',

    [string[]]$Skill,

    [string]$Destination,

    [switch]$Update,

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
    foreach ($source in $selected) {
        $targetPath = Join-Path $root $source.Name
        if (Test-Path -LiteralPath $targetPath) {
            if (-not $Update) {
                Write-Warning "Already exists: $targetPath (use -Update to replace it)"
                continue
            }
            if (-not (Test-Path -LiteralPath $targetPath -PathType Container)) {
                throw "Destination exists and is not a directory: $targetPath"
            }
        }

        $staging = Join-Path $root ('.' + $source.Name + '.staging-' + [guid]::NewGuid().ToString('N'))
        $backup = $null
        try {
            Copy-Item -LiteralPath $source.FullName -Destination $staging -Recurse -Force
            if (-not (Test-Path -LiteralPath (Join-Path $staging 'SKILL.md') -PathType Leaf)) {
                throw "Staged skill is missing SKILL.md: $staging"
            }
            if (Test-Path -LiteralPath $targetPath) {
                $backup = Join-Path $root ('.' + $source.Name + '.backup-' + (Get-Date -Format 'yyyyMMddHHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
                Move-Item -LiteralPath $targetPath -Destination $backup
            }
            try {
                Move-Item -LiteralPath $staging -Destination $targetPath
            } catch {
                if ($backup -and (Test-Path -LiteralPath $backup) -and -not (Test-Path -LiteralPath $targetPath)) {
                    Move-Item -LiteralPath $backup -Destination $targetPath
                }
                throw
            }
            if ($backup) {
                Write-Output "Updated $($source.Name) -> $targetPath (previous copy: $backup)"
            } else {
                Write-Output "Installed $($source.Name) -> $targetPath"
            }
        } finally {
            if (Test-Path -LiteralPath $staging) {
                Remove-Item -LiteralPath $staging -Recurse -Force
            }
        }
    }
}
