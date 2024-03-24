# Set-StrictMode -Version Latest

try {
    Write-Host "Running Job Started Hooks"
}
catch {
    Write-Host "An error occurred: $_"
    exit 0
}
