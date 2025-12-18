$taskNumber = 3
$groupFolderName = Invoke-Expression ".\util\submission_extraction.ps1 -TaskNumber $taskNumber"

# Directory containing the extracted group submission
$studentSubmissionPath = Join-Path (Get-Item $PSScriptRoot).FullName "Task$taskNumber\student_submission"
$groupDirectory = Join-Path $studentSubmissionPath $groupFolderName

Write-Host ''
Write-Host 'Running Task 3 hack script...'
Invoke-Expression "$PSScriptRoot\venv\Scripts\python.exe Task3\tests\task3hack.py '$groupDirectory'"

Copy-Item -Path "$PSScriptRoot\Task3\initial\runsetup.sql" -Destination (Join-Path $groupDirectory "runsetup.sql") -ErrorAction SilentlyContinue
Invoke-Expression "psql -f '$groupDirectory\runsetup.sql' 'postgresql://postgres:postgres@127.0.0.1'" | Out-Null


# Show diffs for .txt and .sql files between the groups two submissions
if (Test-Path (Join-Path $groupDirectory 'OLD')) {
    Get-ChildItem $groupDirectory | Where-Object Name -match '^*\.(txt|sql)' | ForEach-Object {
    Write-Host ''
    $viewDiffInput = Read-Host "Press enter to view $($_.Name) diff (s to skip)"
    if ($viewDiffInput -eq 's') { 
        return 
    }
    code --wait --diff (Join-Path $groupDirectory 'OLD' $_.Name) (Join-Path $groupDirectory $_.Name)
    }
}
