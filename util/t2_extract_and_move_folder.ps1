
$groupFolderName = Invoke-Expression ".\util\submission_extraction.ps1 -TaskNumber 2"

# Directory containing the extracted group submission
$studentSubmissionPath = Join-Path (Get-Item $PSScriptRoot).FullName 'Task2\student_submission'
$groupDirectory = Join-Path $studentSubmissionPath $groupFolderName

# Open the ER diagram and the solution
$erDiagramPath = Join-Path "$groupDirectory" "ER.png"
Start-Process $erDiagramPath
$erDiagramSolutionPath = Join-Path $studentSubmissionPath "..\solutions\ER.png"
$erDiagramSolutionUri = [uri]::EscapeDataString($erDiagramSolutionPath)
Start-Process "chrome" "$erDiagramSolutionUri"

# Show diffs for .txt and .sql files between the groups two submissions
Get-ChildItem $groupDirectory | Where-Object Name -match '^*\.(txt|sql)' | ForEach-Object {
    Write-Host ''
    $viewDiffInput = Read-Host "Press enter to view $($_.Name) diff (s to skip)"
    if ($viewDiffInput -eq 's') { return }
    code --wait --diff (Join-Path $groupDirectory 'OLD' $_.Name) (Join-Path $groupDirectory $_.Name)
}

Copy-Item -Path "$studentSubmissionPath\..\initial\runsetup.sql" -Destination (Join-Path $groupDirectory "runsetup.sql")

$psqlConfig = 'postgresql://postgres:postgres@127.0.0.1'
$command = "psql -f '$groupDirectory\runsetup.sql' '$psqlConfig'"

Remove-Item -Path (Join-Path $groupDirectory 'OUT') -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path (Join-Path $groupDirectory 'OUT') | Out-Null
Invoke-Expression $command *> (Join-Path $groupDirectory 'OUT' 'runsetup_output.txt')