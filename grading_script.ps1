param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$taskNumber
)

$env:TDA357_GRADING_ROOT = (Get-Item $PSScriptRoot).FullName
$env:TDA357_UTIL_ROOT = (Join-Path $env:TDA357_GRADING_ROOT "util")
$env:TDA357_TASKS_ROOT = (Join-Path $env:TDA357_GRADING_ROOT "Tasks")

$groupFolderName = Invoke-Expression ".\util\submission_extraction.ps1 -TaskNumber $taskNumber"
if (-not $groupFolderName) {
    Write-Host "Failed to extract and move submissions."
    exit
}

$env:TDA357_GROUP_SUBMISSION_ROOT = Join-Path $env:TDA357_TASKS_ROOT "Task$taskNumber" "student_submission" $groupFolderName
$env:TDA357_TASK_ROOT = Join-Path $env:TDA357_TASKS_ROOT "Task$taskNumber"

Invoke-Expression "$env:TDA357_UTIL_ROOT\t${taskNumber}_script.ps1"