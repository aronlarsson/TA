if ((-not $env:TDA357_TASK_ROOT) -or -not (Test-Path $env:TDA357_TASK_ROOT)) {
    Write-Host "TDA357_TASK_ROOT is not set or does not exist."
    exit
}

if ((-not $env:TDA357_GROUP_SUBMISSION_ROOT) -or -not (Test-Path $env:TDA357_GROUP_SUBMISSION_ROOT)) {
    Write-Host "TDA357_GROUP_SUBMISSION_ROOT is not set or does not exist."
    exit
}


Copy-Item -Path "$env:TDA357_TASK_ROOT\initial\runsetup.sql" -Destination (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "runsetup.sql") -ErrorAction SilentlyContinue
Copy-Item -Path "$env:TDA357_TASK_ROOT\initial\inserts.sql" -Destination (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "inserts.sql") -ErrorAction SilentlyContinue
Write-Host "Extraction complete and original file deleted."