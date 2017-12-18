# Gotta have a generic utils module, it's tradition

function AskConfirmation {
    Param(
        [Parameter(Mandatory=$True)]
        [string] $Message,
        [Parameter(Mandatory=$True)]
        [ScriptBlock] $Action
    )
    $confirmation = Read-Host "$Message (y/n)"
    if ($confirmation -eq 'y') {
        $Action.Invoke()
    } elseif ($confirmation -eq 'n') {
        Write-Output "It's okay to give up."
    } else {
        Write-Output "I'm sorry, I don't understand. Try again."
        AskConfirmation $Message $Action
    }
}