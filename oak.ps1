$ErrorActionPreference = "Stop"

#If version not set, use latest version
if (-not $env:CLI_VERSION) {
    $CLI_VERSION = (Invoke-WebRequest -Uri "https://api.github.com/repos/oakestra/oakestra-cli/releases/latest" | ConvertFrom-Json).tag_name
    if (-not $CLI_VERSION) {
        Write-Error "Could not determine the latest release version."
        exit 1
    }
} else {
    $CLI_VERSION = $env:CLI_VERSION
}

$BASE_URL="https://raw.githubusercontent.com/oakestra/oakestra-cli/refs/tags"
$DOWNLOAD_URL="$BASE_URL/$CLI_VERSION/oak_go_cli/install.ps1"

try {
    $scriptContent = Invoke-WebRequest -Uri $DOWNLOAD_URL -UseBasicParsing | Select-Object -ExpandProperty Content
    Invoke-Expression $scriptContent
} catch {
    Write-Error "Failed to download or execute install script. Please check your internet connection and permissions."
}
