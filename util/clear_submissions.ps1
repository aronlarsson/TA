$tasksRoot = Join-Path $PSScriptRoot '../Tasks'

foreach ($i in 1..4) {
    Remove-Item -Path (Join-Path $tasksRoot "Task$i\student_submission\*") -Recurse -Force -ErrorAction SilentlyContinue
}