$downloadsPath = (New-Object -ComObject Shell.Application).Namespace('shell:Downloads').Self.Path
$lastFileInDownloads = Get-ChildItem -Path $downloadsPath | Sort-Object LastWriteTime -Descending | Select-Object -First 1

$confirmation = Read-Host "Press enter to extract '$($lastFileInDownloads.Name)' (enter E to exit)"
if ($confirmation -eq 'E') {
    Write-Host "Operation cancelled by user."
    exit
}

$taRootPath = (Get-Item .).Parent.FullName
$taskRootPath = Join-Path $taRootPath "Task1"
if (-not (Test-Path -Path $taskRootPath)) {
    $create = Read-Host "The destination path '$taskRootPath' does not exist. Press Enter to exit, or type C to create the directory."
    if ($create -eq 'C') {
        New-Item -ItemType Directory -Path $taskRootPath | Out-Null
        Write-Host "Directory created at '$taskRootPath'."
    } else {
        exit
    }
} else {
    $confirmMove = Read-Host "Press enter to extract files to '$taskRootPath' (enter E to exit)"
    if ($confirmMove -eq 'E') {
        Write-Host "Operation cancelled by user."
        exit
    }
}

tar -xzf $lastFileInDownloads.FullName -C $taskRootPath

Remove-Item -Path $lastFileInDownloads.FullName

$groupDircetory = Join-Path $taskRootPath ($lastFileInDownloads.Name -replace '\.tar\.gz', '')
Copy-Item -Path "$taskRootPath\initial\runsetup.sql" -Destination (Join-Path $groupDircetory "runsetup.sql") -ErrorAction SilentlyContinue
Copy-Item -Path "$taskRootPath\initial\inserts.sql" -Destination (Join-Path $groupDircetory "inserts.sql") -ErrorAction SilentlyContinue

Write-Host "Extraction complete and original file deleted."