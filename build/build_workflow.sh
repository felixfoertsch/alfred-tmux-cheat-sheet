#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${ROOT_DIR}/dist"
STAGE_DIR="${OUT_DIR}/tmux-workflow"
WORKFLOW_FILE="${OUT_DIR}/alfred-tmux-cheat-sheet.alfredworkflow"

rm -rf "${STAGE_DIR}"
mkdir -p "${STAGE_DIR}" "${OUT_DIR}"

cp "${ROOT_DIR}/info.plist" "${STAGE_DIR}/"
cp "${ROOT_DIR}/icon.png" "${STAGE_DIR}/"
cp -R "${ROOT_DIR}/scripts" "${STAGE_DIR}/"
cp -R "${ROOT_DIR}/data" "${STAGE_DIR}/"

(
	cd "${STAGE_DIR}"
	zip -rq "${WORKFLOW_FILE}" .
)

echo "Created ${WORKFLOW_FILE}"
