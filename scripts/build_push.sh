#!/usr/bin/env bash
set -euo pipefail

aws ecr get-login-password --region "${AWS_REGION}" \
  | docker login --username AWS --password-stdin "${ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"

docker pull "${ORIGINAL}"
docker build -t "$TARGET" "$CONTEXT_DIR"
docker push "${TARGET}"
