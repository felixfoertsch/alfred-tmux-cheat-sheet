#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/tmux_search.sh"

assert_contains() {
	local haystack="${1}"
	local needle="${2}"
	if [[ "${haystack}" != *"${needle}"* ]]; then
		echo "assertion failed: expected output to contain: ${needle}" >&2
		exit 1
	fi
}

# Test: session search returns practical results
out_session="$(bash "${SCRIPT}" "attach session")"
assert_contains "${out_session}" 'Attach to last session'
assert_contains "${out_session}" 'tmux attach'

# Test: new session with name
out_new="$(bash "${SCRIPT}" "new session name")"
assert_contains "${out_new}" 'Start a named session'
assert_contains "${out_new}" 'tmux new -s mysession'

# Test: key bindings show shortcut, not "key-" prefix
out_split="$(bash "${SCRIPT}" "split")"
assert_contains "${out_split}" 'Ctrl+b %'
if [[ "${out_split}" == *'"title":"key-'* ]]; then
	echo "assertion failed: title should not contain key- prefix" >&2
	exit 1
fi

# Test: practical command in subtitle
assert_contains "${out_split}" 'tmux split-window -h'

# Test: configurable prefix
out_custom="$(prefix="Ctrl+a" bash "${SCRIPT}" "split")"
assert_contains "${out_custom}" 'Ctrl+a %'

# Test: no results
out_none="$(bash "${SCRIPT}" "definitely-not-a-real-command")"
assert_contains "${out_none}" '"uid":"no-results"'

echo "tests passed"
