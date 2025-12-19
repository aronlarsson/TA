if ((-not $env:TDA357_TASK_ROOT) -or -not (Test-Path $env:TDA357_TASK_ROOT)) {
    Write-Host "TDA357_TASK_ROOT is not set or directory does not exist."
    exit
}

if ((-not $env:TDA357_GROUP_SUBMISSION_ROOT) -or -not (Test-Path $env:TDA357_GROUP_SUBMISSION_ROOT)) {
    Write-Host "TDA357_GROUP_SUBMISSION_ROOT is not set or directory does not exist."
    exit
}

if ((-not $env:TDA357_GRADING_ROOT) -or -not (Test-Path $env:TDA357_GRADING_ROOT)) {
    Write-Host "TDA357_GRADING_ROOT is not set or directory does not exist."
    exit
}

Read-Host ("Check the following before trying to run the server:`n" + 
    "- Database config is correct(username/password/dbname)`n" + 
    "- There is no package declaration in the files`n" + 
    "Press enter to continue")

Invoke-Expression "psql -f '$env:TDA357_GROUP_SUBMISSION_ROOT\runsetup.sql' 'postgresql://postgres:postgres@127.0.0.1'" | Out-Null

if (Test-Path (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'PortalConnection.py')) {
    Copy-Item -Path "$env:TDA357_TASK_ROOT\initial\python\PortalServer.py" -Destination (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "PortalServer.py") -ErrorAction SilentlyContinue
    $process = Start-Process -PassThru pwsh "-NoExit -Command $env:TDA357_GRADING_ROOT\venv\Scripts\python.exe '$env:TDA357_GROUP_SUBMISSION_ROOT\PortalServer.py'"
} elseif (Test-Path (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT 'PortalConnection.java')) {
    Copy-Item -Path "$env:TDA357_TASK_ROOT\initial\java\PortalServer.java" -Destination (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "PortalServer.java") -ErrorAction SilentlyContinue
    $cp = "$env:TDA357_GROUP_SUBMISSION_ROOT;$env:TDA357_TASK_ROOT\initial\java\postgresql-42.7.4.jar"
    javac -cp $cp (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "PortalConnection.java")
    javac -cp $cp (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "PortalServer.java")
    javac -cp $cp (Join-Path $env:TDA357_GROUP_SUBMISSION_ROOT "TestPortal.java")
    $process = Start-Process -PassThru pwsh "-NoExit -Command java -cp '$cp' PortalServer"
}

Read-Host "Press enter to terminate the server"
Stop-Process $process