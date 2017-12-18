# Given a path, organises all the files underneath it into year-month subdirectories.
# Useful for a big folder full of unorganised JPEGs. Only uses file modified date,
# not EXIF data.
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
  [string]$Path,
  # If no DestPath, organises within Path
  [Parameter()]
  [string]$DestPath = $Path,
  [Parameter()]
  [boolean]$Confirm = $true,
  [Parameter()]
  [switch]$WhatIf = $false
)

Import-Module ".\FileFunctions"
Import-Module ".\Utils"

if ($WhatIf) {
    $WhatIfPreference = $True
}

$DateFolderFormat = "yyyy-MM"

Write-Verbose "Path: $Path"
Write-Verbose "DestPath: $DestPath"

if (-Not (Test-Path $Path)) {
    Write-Error "Source path '$Path' not found."
    return
}

if (-Not (Test-Path $DestPath)) {
    Write-Error "Destination path '$DestPath' not found."
    return
}

Write-Output "Scanning '$Path'…"

function Get-FileDate {
    Param(
        [System.IO.FileInfo] $File
    )
    # TODO Check EXIF if available?
    return [DateTime] $File.LastWriteTime
}
# Returns the directory path that this file should be moved to.
function TargetLocation($File) {
    [DateTime] $modified = Get-FileDate($File)
    $datefolder = Get-Date -Date $modified -Format $DateFolderFormat
    Get-AbsolutePath (Join-Path $DestPath $datefolder)
}

function RunCommand() {
    # FIXME doesn't handle file name conflicts, some files just don't get moved.
    $ItemsToMove.ForEach{
        $Dest = TargetLocation $_
        if (-Not (Test-Path $Dest)) {
            Mkdir -Path $Dest
        }
        Move-Item -Path $_.FullName -Destination $Dest
    }
    Write-Output "Done."
}

[array]$Items = Get-ChildItem -Path $Path -File -Recurse
if ($Items.Length -eq 0) {
    Write-Output "No files were found."
    return
}
[array]$ItemsToMove = $Items | Where-Object { $_.Directory.FullName -ne (TargetLocation $_) }

if ($ItemsToMove.Length -gt 0) {
    Write-Output "Found $($Items.Length) files, of which $($ItemsToMove.Length) need moving."
    if ($Confirm) {
        AskConfirmation "Do you want to move these files" { RunCommand }
    } else {
        RunCommand
    }
} else {
    Write-Output "No files need moving. I'm done! 😊"
}