param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$taskNumber
)

$env:TDA357_GRADING_ROOT = (Get-Item $PSScriptRoot).FullName
$env:TDA357_UTIL_ROOT = (Join-Path $env:TDA357_GRADING_ROOT "util")
$tasksRoot = (Join-Path $env:TDA357_GRADING_ROOT "Tasks")
$env:TDA357_TASK_NUMBER = $taskNumber

$groupFolderName = Invoke-Expression "$env:TDA357_UTIL_ROOT\submission_extraction.ps1"
if (-not $groupFolderName) {
    Write-Host "Failed to extract and move submissions."
    exit
}

$env:TDA357_TASK_ROOT = Join-Path $tasksRoot "Task$taskNumber"
$env:TDA357_GROUP_SUBMISSION_ROOT = Join-Path $env:TDA357_TASK_ROOT "student_submission" $groupFolderName

Invoke-Expression "$env:TDA357_UTIL_ROOT\t${taskNumber}_script.ps1"

Copy-Item -Path "$env:TDA357_TASK_ROOT\initial\runsetup.sql" -Destination (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "runsetup.sql") -ErrorAction SilentlyContinue
Copy-Item -Path "$env:TDA357_TASK_ROOT\initial\inserts.sql" -Destination (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "inserts.sql") -ErrorAction SilentlyContinue
Invoke-Expression "psql -f '$env:TDA357_GROUP_SUBMISSION_ROOT\runsetup.sql' 'postgresql://postgres:postgres@127.0.0.1'" | Out-Null

Invoke-Expression "$env:TDA357_UTIL_ROOT\get_diff.ps1"