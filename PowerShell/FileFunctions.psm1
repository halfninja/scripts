
# Copied from StackOverflow, obviously
function Get-AbsolutePath
{
    Param(
        [string] $Path
    )
    # System.IO.Path.Combine has two properties making it necesarry here:
    #   1) correctly deals with situations where $Path (the second term) is an absolute path
    #   2) correctly deals with situations where $Path (the second term) is relative
    # (join-path) commandlet does not have this first property
    $Path = [System.IO.Path]::Combine( ((Get-Location).Path), ($Path) )

    # Normalises any relative path modifiers like '..' and '.'
    $Path = [System.IO.Path]::GetFullPath($Path)

    return $Path
}
