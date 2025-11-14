$lastFileInDownloads = Get-ChildItem -Path "C:\Users\Aron\Downloads" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

$confirmation = Read-Host "Press enter to extract '$($lastFileInDownloads.Name)' (enter E to exit)"
if ($confirmation -eq 'E') {
    Write-Host "Operation cancelled by user."
    exit
}

$destination = Read-Host "Enter the destination folder path starting from C:\TA\ (blank for exit)"
if ([string]::IsNullOrWhiteSpace($destination)) {
    Write-Host "No destination provided. Exiting script."
    exit
}

$destinationPath = Join-Path -Path "C:\TA" -ChildPath $destination
if (-not (Test-Path -Path $destinationPath)) {
    $create = Read-Host "The destination path '$destinationPath' does not exist. Press Enter to exit, or type C to create the directory."
    if ($create -eq 'C') {
        New-Item -ItemType Directory -Path $destinationPath | Out-Null
        Write-Host "Directory created at '$destinationPath'."
    } else {
        exit
    }
} else {
    $confirmMove = Read-Host "Press enter to extract files to '$destinationPath' (enter E to exit)"
    if ($confirmMove -eq 'E') {
        Write-Host "Operation cancelled by user."
        exit
    }
}

tar -xzf $lastFileInDownloads.FullName -C $destinationPath

Remove-Item -Path $lastFileInDownloads.FullName
Write-Host "Extraction complete and original file deleted."