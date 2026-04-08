#!/usr/bin/env bash

set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$CURRENT_DIR"

export JAVA_VERSION="${JAVA_VERSION:-22}"
export HUDI_VERSION="${HUDI_VERSION:-0.14.2-SNAPSHOT}"
export TRINO_VERSION="${TRINO_VERSION:-449}"
export TRINO_VERSION_TAG=${TRINO_VERSION}

export HUDI_TAR="jars/hudi-trino-bundle-${HUDI_VERSION}.jar"
export TAR="jars/trino-server-${TRINO_VERSION}.tar"
export CLI="jars/trino-cli-${TRINO_VERSION}-executable.jar"

for f in "${TAR}" "${CLI}" "${HUDI_TAR}"; do
	if [[ ! -f "$f" ]]; then
		echo "Missing required file: ${f}" >&2
		echo "Download or build Trino and place the server tarball and CLI jar under jars/ (see README.md)." >&2
		exit 1
	fi
done

docker build \
	--build-arg "JAVA_VERSION=${JAVA_VERSION}" \
	--build-arg "TRINO_VERSION=${TRINO_VERSION}" \
	-t apachehudi/trino:latest \
    -t apachehudi/trino:"$TRINO_VERSION_TAG" \
	-f Dockerfile \
	.

echo "Built ${IMAGE_NAME}:${IMAGE_TAG}"
