$downloadsPath = (New-Object -ComObject Shell.Application).Namespace('shell:Downloads').Self.Path
$allSubmissions = Get-ChildItem -Path $downloadsPath | Where-Object Name -like 'Task*.tar.gz'
$lastSubmissionInDownloads = $allSubmissions | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$groupFolderName = ($lastSubmissionInDownloads.Name -replace '(Task \d_group\d{1,3})( \(\d\))?.tar.gz', '$1')

if (-not $lastSubmissionInDownloads) {
    Write-Host "No .tar.gz files found in the Downloads folder."
    exit
}

$confirmation = Read-Host "Press enter to extract '$($lastSubmissionInDownloads.Name)' (enter E to exit)"
if ($confirmation -eq 'E') {
    Write-Host "Operation cancelled by user."
    exit
}

$allSubmissionsFromGroup = $allSubmissions | Where-Object Name -like "$groupFolderName*.tar.gz"
$tmpSubmissionsPath = Join-Path $downloadsPath 'submission_tmp/'

New-Item -ItemType Directory -Path $tmpSubmissionsPath -Force | Out-Null

for ($i = 0; $i -lt $allSubmissionsFromGroup.Count; $i++) {
    $submission = $allSubmissionsFromGroup[$i]
    tar -xzf $submission.FullName -C $tmpSubmissionsPath
    Rename-Item -Path (Join-Path $tmpSubmissionsPath $groupFolderName) -NewName "${groupFolderName}_$i"
    Remove-Item -Path $submission.FullName
}

# Sort submissions by the LastWriteTime of FIRE_INFO.txt
$sortedSubmissions = Get-ChildItem -Path $tmpSubmissionsPath | Sort-Object -Property { `
        (Get-ChildItem $_ | Where-Object Name -like "FIRE_INFO.txt" | Select-Object -First 1 | `
            Get-Content | Select-String -Pattern '^submitted on \d{4}-\d{2}-\d{2} \d{2}:\d{2}' | `
            ForEach-Object { ($_ -replace 'submitted on ','') -replace '\.',''} `
        ) `
    } -Descending


$sortedSubmissions | ForEach-Object {
    (Get-ChildItem $_ | Where-Object Name -like "FIRE_INFO.txt" | Select-Object -First 1 | Get-Content | Select-String -Pattern '^submitted on \d{4}-\d{2}-\d{2} \d{2}:\d{2}')
}

$gradingRootPath = (Get-Item .).FullName
$studentSubmissionPath = Join-Path $gradingRootPath "Task2" 'student_submission'
if (-not (Test-Path -Path $studentSubmissionPath)) {
    $createDirInput = Read-Host "The destination path '$studentSubmissionPath' does not exist. Press Enter to exit, or type C to create the directory."
    if ($createDirInput -ne 'C') { exit }

    New-Item -ItemType Directory -Path $studentSubmissionPath | Out-Null
    Write-Host "Directory created at '$studentSubmissionPath'."
}

$confirmMove = Read-Host "Press enter to extract files to '$studentSubmissionPath' (enter E to exit)"
if ($confirmMove -eq 'E') {
    Write-Host "Operation cancelled by user."
    exit
}

# Clear existing contents in the student submission directory
Remove-Item -Path $studentSubmissionPath\* -Recurse -Force -ErrorAction SilentlyContinue

# Move the selected groups' submissions to the student submission directory (the older one is moved to the OLD folder inside the newer one)
# First remove the appended index from the submission name, so that it is not present after moving the submission
# Pass the moved item through Select-Object and ForEach-Object to access the moved item through $_ variable
# Use the $_ variable to move the older submission to the OLD folder inside the newer submission
Rename-Item $sortedSubmissions[0] -NewName ($sortedSubmissions[0].Name -replace '_\d$','') -PassThru | Move-Item -Destination $studentSubmissionPath -PassThru | Select-Object -First 1 | `
    ForEach-Object { Move-Item $sortedSubmissions[1] -Destination (Join-Path $_.FullName 'OLD') -Force -ErrorAction SilentlyContinue }



# Clean up temporary submissions directory
Remove-Item -Path $tmpSubmissionsPath -Recurse -Force -ErrorAction SilentlyContinue

# Directory containing the extracted group submission
$groupDirectory = Join-Path $studentSubmissionPath $groupFolderName

# Open the ER diagram and the solution
$erDiagramPath = Join-Path "$groupDirectory" "ER.png"
Start-Process $erDiagramPath
$erDiagramSolutionPath = Join-Path $studentSubmissionPath "..\solutions\ER.png"
$erDiagramSolutionUri = [uri]::EscapeDataString($erDiagramSolutionPath)
Start-Process "chrome" "$erDiagramSolutionUri"

# Show diffs for .txt and .sql files between the groups two submissions
Get-ChildItem $groupDirectory | Where-Object Name -match '^*\.(txt|sql)' | ForEach-Object {
    Write-Host ''
    $viewDiffInput = Read-Host "Press enter to view $($_.Name) diff (s to skip)"
    if ($viewDiffInput -eq 's') { return }
    code --wait --diff (Join-Path $groupDirectory 'OLD' $_.Name) (Join-Path $groupDirectory $_.Name)
}

Copy-Item -Path "$studentSubmissionPath\..\initial\runsetup.sql" -Destination (Join-Path $groupDirectory "runsetup.sql")

$psqlConfig = 'postgresql://postgres:postgres@127.0.0.1'
$command = "psql -f '$groupDirectory\runsetup.sql' '$psqlConfig'"

Remove-Item -Path (Join-Path $groupDirectory 'OUT') -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path (Join-Path $groupDirectory 'OUT') | Out-Null
Invoke-Expression $command *> (Join-Path $groupDirectory 'OUT' 'runsetup_output.txt')