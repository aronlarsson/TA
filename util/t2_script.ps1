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

# Show diffs for .txt and .sql files between the groups two submissions
Get-ChildItem $env:TDA357_GROUP_SUBMISSION_ROOT | Where-Object Name -match '^*\.(txt|sql)' | ForEach-Object {
    Write-Host ''
    $viewDiffInput = Read-Host "Press enter to view $($_.Name) diff (s to skip)"
    if ($viewDiffInput -eq 's') { return }
    code --wait --diff (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'OLD' $_.Name) (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT $_.Name)
}

Copy-Item -Path "$env:TDA357_TASK_ROOT\initial\runsetup.sql" -Destination (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "runsetup.sql")

$psqlConfig = 'postgresql://postgres:postgres@127.0.0.1'
$command = "psql -f '$env:TDA357_GROUP_SUBMISSION_ROOT\runsetup.sql' '$psqlConfig'"

Remove-Item -Path (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'OUT') -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'OUT') | Out-Null
Invoke-Expression $command *> (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'OUT' 'runsetup_output.txt')