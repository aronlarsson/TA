if ((-not $env:TDA357_GROUP_SUBMISSION_ROOT) -or -not (Test-Path $env:TDA357_GROUP_SUBMISSION_ROOT)) {
    Write-Host "TDA357_GROUP_SUBMISSION_ROOT is not set or directory does not exist."
    exit
}

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