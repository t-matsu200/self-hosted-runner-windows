$config_args = ""

if ($env:RUNNER_EPHEMERAL -eq "true") {
  Write-Host "Add option: --ephemeral"
  $config_args = "$config_args --ephemeral"
}

if ($env:DISABLE_RUNNER_UPDATE -eq "true") {
  Write-Host "Add option: --disableupdate"
  $config_args = "$config_args --disableupdate"
}

if ($env:RUNNER_LABEL -ne "") {
  Write-Host "Add option: --labels $env:RUNNER_LABEL"
  $config_args = "$config_args --labels $env:RUNNER_LABEL"
}

if ($env:RUNNER_ORG -ne "" -and $env:RUNNER_REPO -ne "" -and $env:RUNNER_ENTERPRISE -ne "") {
  $ATTACH = "$env:RUNNER_ORG/$env:RUNNER_REPO"
}
elseif ($env:RUNNER_ORG -ne "") {
  $ATTACH = $env:RUNNER_ORG
}
elseif ($env:RUNNER_REPO -ne "") {
  $ATTACH = $env:RUNNER_REPO
}
elseif ($env:RUNNER_ENTERPRISE -ne "") {
  $ATTACH = "enterprises/$env:RUNNER_ENTERPRISE"
}
else {
  Write-Error "At least one of RUNNER_ORG, RUNNER_REPO, or RUNNER_ENTERPRISE must be set"
  exit 1
}

Write-Host "URL: $env:GITHUB_URL/$ATTACH"

if (-not $env:RUNNER_NAME_PREFIX) {
  $runner_name = "win-action-$env:COMPUTERNAME"
} else {
  $runner_name = "$env:RUNNER_NAME_PREFIX-$env:COMPUTERNAME"
}

.\config.cmd `
  --unattended --replace `
  --name "$runner_name" `
  --url "$env:GITHUB_URL/$ATTACH" `
  --pat "$env:GITHUB_ACCESS_TOKEN" `
  --runnergroup "$env:RUNNER_GROUPS" `
  --work "_work" `
  $config_args

.\run.cmd
