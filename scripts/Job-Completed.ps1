# Set-StrictMode -Version Latest

try {
    Write-Host "Job completed hook"

    Write-Host "Job completed: $env:GITHUB_REPOSITORY $env:GITHUB_JOB"
    Write-Host "WORKFLOW: $env:GITHUB_WORKFLOW"
    Write-Host "RUNNER_NAME: $env:RUNNER_NAME"
    Write-Host "RUN_ID: $env:GITHUB_RUN_ID"
    Start-Sleep -Seconds 2147483
}
catch {
    Write-Host "An error occurred: $_"
    exit 0
}
