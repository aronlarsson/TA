if ((-not $env:TDA357_TASK_ROOT) -or -not (Test-Path $env:TDA357_TASK_ROOT)) {
    Write-Host "TDA357_TASK_ROOT is not set or does not exist."
    exit
}

if ((-not $env:TDA357_GROUP_SUBMISSION_ROOT) -or -not (Test-Path $env:TDA357_GROUP_SUBMISSION_ROOT)) {
    Write-Host "TDA357_GROUP_SUBMISSION_ROOT is not set or does not exist."
    exit
}

Write-Host ''
Write-Host 'Running Task 3 hack script...'
Invoke-Expression "$env:TDA357_GRADING_ROOT\venv\Scripts\python.exe $env:TDA357_TASK_ROOT\tests\task3hack.py '$env:TDA357_GROUP_SUBMISSION_ROOT'"
