#!/bin/bash

#If version not set, use latest version
if [ -z "$CLI_VERSION" ]; then
    CLI_VERSION=$(curl -s "https://api.github.com/repos/oakestra/oakestra-cli/releases/latest" | grep '"tag_name":' | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
    if [ -z "$CLI_VERSION" ]; then
    fail "Could not determine the latest release version."
    fi
fi

BASE_URL="https://raw.githubusercontent.com/oakestra/oakestra-cli/refs/tags"
DOWNLOAD_URL="$BASE_URL/$CLI_VERSION/oak_go_cli/install.sh"

curl -sfL $DOWNLOAD_URL | bash
