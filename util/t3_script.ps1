if ((-not $env:TDA357_TASK_ROOT) -or -not (Test-Path $env:TDA357_TASK_ROOT)) {
    Write-Host "TDA357_TASK_ROOT is not set or directory does not exist."
    $taskRoot = Join-Path $PSScriptRoot "..\Tasks\Task3"
    Write-Host "Assuming task root path is $taskRoot"
    $exit = Read-Host "Press Enter to continue, or type E to exit"
    if ($exit -eq 'E') {
        exit
    }
    $env:TDA357_TASK_ROOT = $taskRoot
}

if ((-not $env:TDA357_GROUP_SUBMISSION_ROOT) -or -not (Test-Path $env:TDA357_GROUP_SUBMISSION_ROOT)) {
    Write-Host "TDA357_GROUP_SUBMISSION_ROOT is not set or directory does not exist."
    $groupSubmissionRoot = (Get-ChildItem (Join-Path $env:TDA357_TASK_ROOT "student_submission") | Where-Object { $_.PSIsContainer } | Select-Object -First 1).FullName
    Write-Host "Assuming group submission root path is $groupSubmissionRoot"
    $exit = Read-Host "Press Enter to continue, or type E to exit"
    if ($exit -eq 'E') {
        exit
    }
    $env:TDA357_GROUP_SUBMISSION_ROOT = $groupSubmissionRoot
}

if ((-not $env:TDA357_GRADING_ROOT) -or -not (Test-Path $env:TDA357_GRADING_ROOT)) {
    Write-Host "TDA357_GRADING_ROOT is not set or directory does not exist."
    $gradingRoot = Join-Path $PSScriptRoot "..\"
    Write-Host "Assuming grading root path is $gradingRoot"
    $exit = Read-Host "Press Enter to continue, or type E to exit"
    if ($exit -eq 'E') {
        exit
    }
    $env:TDA357_GRADING_ROOT = $gradingRoot
}

Write-Host ''
Write-Host 'Running Task 3 hack script...'
Invoke-Expression "$env:TDA357_GRADING_ROOT\venv\Scripts\python.exe $env:TDA357_TASK_ROOT\tests\task3hack.py '$env:TDA357_GROUP_SUBMISSION_ROOT'"
