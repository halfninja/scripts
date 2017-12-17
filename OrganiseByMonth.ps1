# Given a path, organises all the files underneath it into year-month subdirectories.
# Useful for a big folder full of unorganised JPEGs. Only uses file modified date,
# not EXIF data.

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
  [string]$Path,
  [Parameter(Mandatory=$False)]
  [boolean]$Copy
)

$DateFolderFormat = "yyyy-MM"

echo "Looking in $Path"

function Get-AbsolutePath ($Path)
{
    # System.IO.Path.Combine has two properties making it necesarry here:
    #   1) correctly deals with situations where $Path (the second term) is an absolute path
    #   2) correctly deals with situations where $Path (the second term) is relative
    # (join-path) commandlet does not have this first property
    $Path = [System.IO.Path]::Combine( ((pwd).Path), ($Path) );

    # Normalises any relative path modifiers like '..' and '.'
    $Path = [System.IO.Path]::GetFullPath($Path);

    return $Path;
}

# Returns the directory path that this file should be moved to.
function TargetLocation($File) {
    $modified = $_.LastWriteTime
    $datefolder = Get-Date -Date $modified -Format $DateFolderFormat
    Get-AbsolutePath (Join-Path $Path $datefolder)
}

function runCommand() {
    $ItemsToMove.ForEach{
        $Dest = TargetLocation $_
        if (-Not (Test-Path $Dest)) {
            Mkdir -Path $Dest
        }
        Move-Item -Path $_.FullName -Destination $Dest
    }
}

function askConfirmation() {
  $confirmation = Read-Host "Are you Sure You Want To Proceed (y/n)"
  if ($confirmation -eq 'y') {
      runCommand
  } elseif ($confirmation -eq 'n') {
      echo "It's okay to give up."
  } else {
      echo "I'm sorry, I don't understand. Try again."
      askConfirmation
  }
}

$Items = Get-ChildItem -Path $Path -File -Recurse 
$ItemsToMove = $Items | Where-Object { $_.Directory.FullName -ne (TargetLocation $_) }

if ($ItemsToMove.Length -gt 0) {
    echo "Found $($Items.Length) files, of which $($ItemsToMove.Length) need moving."
    askConfirmation
} else {
    echo "No files need moving. I'm done!"
}