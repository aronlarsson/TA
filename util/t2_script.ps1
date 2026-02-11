if ((-not $env:TDA357_TASK_ROOT) -or -not (Test-Path $env:TDA357_TASK_ROOT)) {
    Write-Host "TDA357_TASK_ROOT is not set or directory does not exist."
    exit
}

if ((-not $env:TDA357_GROUP_SUBMISSION_ROOT) -or -not (Test-Path $env:TDA357_GROUP_SUBMISSION_ROOT)) {
    Write-Host "TDA357_GROUP_SUBMISSION_ROOT is not set or directory does not exist."
    exit
}

# Open the ER diagram and the 
$erFileEndings = '.png', '.jpg', '.gif', '.pdf'
foreach ($fileEnding in $erFileEndings) {
    $erDiagramPath = Join-Path "$env:TDA357_GROUP_SUBMISSION_ROOT" "ER$fileEnding"
    if (Test-Path $erDiagramPath) {
        break
    } 
    $erDiagramPath = $null
}
if (-not $erDiagramPath) {
    Write-Host 'ER diagram not found, skipping opening student diagram'
} else {
    Start-Process $erDiagramPath
}
$erDiagramSolutionPath = Join-Path $env:TDA357_TASK_ROOT "solutions\ER.png"
$erDiagramSolutionUri = [uri]::EscapeDataString($erDiagramSolutionPath)
Start-Process "chrome" "$erDiagramSolutionUri"

code -r (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'ER-schema.txt')
code -r (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'FD.txt')
code -r (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'tables.sql')