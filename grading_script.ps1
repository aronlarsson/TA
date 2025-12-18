param(
    [Parameter(Mandatory=$true, Position=0)]
    [int]$taskNumber
)

$gradingRoot = (Get-Item $PSScriptRoot).FullName
$env:TDA357_UTIL_ROOT = (Join-Path $gradingRoot "util")
$tasksRoot = (Join-Path $gradingRoot "Tasks")
$env:TDA357_TASK_NUMBER = $taskNumber

$groupFolderName = Invoke-Expression "$env:TDA357_UTIL_ROOT\submission_extraction.ps1"
if (-not $groupFolderName) {
    Write-Host "Failed to extract and move submissions."
    exit
}

$env:TDA357_TASK_ROOT = Join-Path $tasksRoot "Task$taskNumber"
$env:TDA357_GROUP_SUBMISSION_ROOT = Join-Path $env:TDA357_TASK_ROOT "student_submission" $groupFolderName

Invoke-Expression "$env:TDA357_UTIL_ROOT\t${taskNumber}_script.ps1"