param(
    [string]$Destination = (Join-Path $HOME '.agents/skills'),

    [switch]$Migrate
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sourcePath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'skills')).TrimEnd('\')
$linkPath = [System.IO.Path]::GetFullPath($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)).TrimEnd('\')
$parentPath = [System.IO.Path]::GetDirectoryName($linkPath)

if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
    throw "Skill source directory is missing: $sourcePath"
}
if (-not $parentPath -or
    $linkPath.Equals($sourcePath, [System.StringComparison]::OrdinalIgnoreCase) -or
    $linkPath.StartsWith($sourcePath + '\', [System.StringComparison]::OrdinalIgnoreCase) -or
    $sourcePath.StartsWith($linkPath + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Destination would create a junction cycle: $linkPath"
}

New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
$existing = Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue
if ($existing) {
    if ($existing.LinkType -eq 'Junction') {
        $existingTarget = [System.IO.Path]::GetFullPath([string](@($existing.Target)[0])).TrimEnd('\')
        if ($existingTarget.Equals($sourcePath, [System.StringComparison]::OrdinalIgnoreCase)) {
            Write-Output "Already linked $linkPath -> $sourcePath"
        } else {
            Write-Warning "Different junction already exists: $linkPath -> $existingTarget"
        }
        return
    }
    if ($existing.LinkType -or -not $existing.PSIsContainer) {
        Write-Warning "Different item already exists: $linkPath"
        return
    }
    if (-not $Migrate) {
        Write-Warning "Directory already exists: $linkPath (use -Migrate to back it up and create a junction)"
        return
    }
}

$backup = $null
try {
    if ($existing) {
        $backupName = '.' + [System.IO.Path]::GetFileName($linkPath) + '.backup-' + (Get-Date -Format 'yyyyMMddHHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0, 8)
        $backup = [System.IO.Path]::GetFullPath((Join-Path $parentPath $backupName))
        if (-not [System.IO.Path]::GetDirectoryName($backup).Equals($parentPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Backup path is outside the destination parent: $backup"
        }
        Move-Item -LiteralPath $linkPath -Destination $backup
    }
    New-Item -ItemType Junction -Path $linkPath -Target $sourcePath | Out-Null
    if ($backup) {
        Write-Output "Linked $linkPath -> $sourcePath (previous directory: $backup)"
    } else {
        Write-Output "Linked $linkPath -> $sourcePath"
    }
} catch {
    if ($backup -and (Test-Path -LiteralPath $backup) -and -not (Get-Item -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue)) {
        Move-Item -LiteralPath $backup -Destination $linkPath
    }
    throw
}
