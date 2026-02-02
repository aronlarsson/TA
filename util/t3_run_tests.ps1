$groupDirectory = (Get-ChildItem (Join-Path (Get-Item $PSScriptRoot).FullName 'Task3/student_submission') | Where-Object Name -like 'Task 3_group*' | Select-Object -First 1).FullName

Write-Host "Testing group directory $groupDirectory"

Invoke-Expression "$PSScriptRoot\venv\Scripts\python.exe Task3\tests\task3hack.py '$groupDirectory'"