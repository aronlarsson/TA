param(
    [int]$TaskNumber
)

$groupDirectory = (Get-ChildItem (Join-Path (Get-Item $PSScriptRoot).FullName "Task$TaskNumber/student_submission") | Where-Object Name -like "Task ${TaskNumber}_group*" | Select-Object -First 1).FullName

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