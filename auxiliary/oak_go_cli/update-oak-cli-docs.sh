#!/bin/bash

# NOTE: This is a shortcut cmd that is defined in package.json
# It can be run like this: 'npm run update-oak-cli-docs'

set -euo pipefail

# Ask for the version
read -r -p "Enter version (default: main): " GIVEN_VERSION

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
AUTO_DOC_PATH="${SCRIPT_DIR}/documentation_automation"
IMAGE_NAME="oak-cli-documentation-automator"
CONTAINER_NAME="oak-cli-docs-automator"

if [ -z "$GIVEN_VERSION" ] || [ "$GIVEN_VERSION" == "main" ]; then
    TARGET_DIR="${REPO_ROOT}/content/docs/reference/cli"
else
    TARGET_DIR="${REPO_ROOT}/content/version/${GIVEN_VERSION}/docs/reference/cli"
fi

# Fail before touching anything, otherwise the cleanup below would run in the wrong place.
if [ ! -d "${TARGET_DIR}" ]; then
    echo "Target directory ${TARGET_DIR} does not exist" >&2
    exit 1
fi

# The Dockerfile clones oakestra-cli, so a cached build would silently regenerate stale docs.
docker build --no-cache -t "${IMAGE_NAME}" "${AUTO_DOC_PATH}"

docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
trap 'docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true' EXIT
docker create --name "${CONTAINER_NAME}" "${IMAGE_NAME}" >/dev/null

# The generated docs already contain _index.md (see the Dockerfile).
find "${TARGET_DIR}" -mindepth 1 -delete
docker cp "${CONTAINER_NAME}:/app/oak_go_cli/docs/." "${TARGET_DIR}"

echo "CLI docs written to ${TARGET_DIR}"
