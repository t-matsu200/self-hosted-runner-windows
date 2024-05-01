# Set-StrictMode -Version Latest

try {
    Write-Host "Job completed hook"

    Write-Host "Job completed: $env:GITHUB_REPOSITORY $env:GITHUB_JOB"
    Write-Host "WORKFLOW: $env:GITHUB_WORKFLOW"
    Write-Host "RUNNER_NAME: $env:RUNNER_NAME"
    Write-Host "RUN_ID: $env:GITHUB_RUN_ID"

    $tmpDirectory = "C:\actions-runner\runner-temp"
    if (Test-Path $tmpDirectory -PathType Container) {
        Remove-Item -Path $tmpDirectory -Recurse -Force
    } else {
        Write-Host "Directory does not exist."
    }
}
catch {
    Write-Host "An error occurred: $_"
    exit 0
}
