if ((-not $env:TDA357_TASK_ROOT) -or -not (Test-Path $env:TDA357_TASK_ROOT)) {
    Write-Host "TDA357_TASK_ROOT is not set or does not exist."
    exit
}

if ((-not $env:TDA357_GROUP_SUBMISSION_ROOT) -or -not (Test-Path $env:TDA357_GROUP_SUBMISSION_ROOT)) {
    Write-Host "TDA357_GROUP_SUBMISSION_ROOT is not set or does not exist."
    exit
}

Copy-Item -Path "$env:TDA357_TASK_ROOT\initial\runsetup.sql" -Destination (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "runsetup.sql") -ErrorAction SilentlyContinue
Invoke-Expression "psql -f '$env:TDA357_GROUP_SUBMISSION_ROOT\runsetup.sql' 'postgresql://postgres:postgres@127.0.0.1'" | Out-Null

# Show diffs for .txt and .sql files between the groups two submissions
if (Test-Path (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'OLD')) {
    Get-ChildItem $env:TDA357_GROUP_SUBMISSION_ROOT | Where-Object Name -match '^*\.(txt|sql)' | ForEach-Object {
    Write-Host ''
    $viewDiffInput = Read-Host "Press enter to view $($_.Name) diff (s to skip)"
    if ($viewDiffInput -eq 's') { 
        return 
    }
    code --wait --diff (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'OLD' $_.Name) (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT $_.Name)
    }
}

Read-Host "Press enter to terminate the server"
Stop-Process $process