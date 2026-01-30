param(
    [string]$StartOrStop = $(Read-Host 'Start or stop')
)

while ($StartOrStop -ne 'start' -and $StartOrStop -ne 'stop') {
    $StartOrStop = Read-Host 'Start or stop'
}

start-process pwsh "-command & { get-service 'postgres*' | $StartOrStop-service -PassThru; Read-Host 'Press enter to exit'}" -verb runas