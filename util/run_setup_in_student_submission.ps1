param(
    [Parameter(Mandatory=$true)]
    [int]$TaskNumber
)

$studentSubmissionFolder = Join-Path $PSScriptRoot "..\Tasks\Task$TaskNumber\student_submission\"
$groupSubmissionFolder = Get-ChildItem $studentSubmissionFolder | Select-Object -First 1
$groupRunSetupFile = Get-ChildItem $groupSubmissionFolder | Where-Object Name -like 'runsetup.sql'

if (-not $groupRunSetupFile) {
    Write-Host "runsetup.sql not found in $groupSubmissionFolder"
    return
}

psql -f $groupRunSetupFile.FullName 'postgres://postgres:postgres@127.0.0.1'