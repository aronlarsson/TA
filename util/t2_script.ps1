if ((-not $env:TDA357_TASK_ROOT) -or -not (Test-Path $env:TDA357_TASK_ROOT)) {
    Write-Host "TDA357_TASK_ROOT is not set or does not exist."
    exit
}

if ((-not $env:TDA357_GROUP_SUBMISSION_ROOT) -or -not (Test-Path $env:TDA357_GROUP_SUBMISSION_ROOT)) {
    Write-Host "TDA357_GROUP_SUBMISSION_ROOT is not set or does not exist."
    exit
}

# Open the ER diagram and the solution
$erDiagramPath = Join-Path "$env:TDA357_GROUP_SUBMISSION_ROOT" "ER.png"
Start-Process $erDiagramPath
$erDiagramSolutionPath = Join-Path $env:TDA357_TASK_ROOT "solutions\ER.png"
$erDiagramSolutionUri = [uri]::EscapeDataString($erDiagramSolutionPath)
Start-Process "chrome" "$erDiagramSolutionUri"