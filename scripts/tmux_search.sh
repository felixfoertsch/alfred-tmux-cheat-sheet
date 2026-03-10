#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_FILE="${SCRIPT_DIR}/../data/tmux_commands.tsv"
QUERY="${1:-}"
PREFIX="${prefix:-Ctrl+b}"

awk -F'\t' -v query="${QUERY}" -v max=25 -v pfx="${PREFIX}" '
BEGIN {
	n = split(tolower(query), words, /[[:space:]]+/)
	count = 0
	printf "{\"items\":["
}

{
	name = $1; desc = $2; cmd = $3; shortcut = $4
	if (name == "") next
	gsub(/{prefix}/, pfx, shortcut)

	blob = tolower(name " " desc " " cmd " " shortcut)
	for (i = 1; i <= n; i++) {
		if (index(blob, words[i]) == 0) next
	}

	if (count >= max) exit

	# Key bindings: title = shortcut + desc, subtitle = empty
	# Commands: title = desc, subtitle = command
	if (shortcut != "") {
		title = shortcut " — " desc
		subtitle = cmd
		copy = shortcut
	} else {
		title = desc
		subtitle = cmd
		copy = cmd
	}

	# arg = both lines for clipboard
	if (subtitle != "") {
		arg = title "\n" subtitle
	} else {
		arg = title
	}

	if (count > 0) printf ","
	count++

	printf "{\"uid\":\"%s\",", escape(name "-" count)
	printf "\"title\":\"%s\",", escape(title)
	printf "\"subtitle\":\"%s\",", escape(subtitle)
	printf "\"arg\":\"%s\",", escape(arg)
	printf "\"match\":\"%s\",", escape(name " " desc " " cmd " " shortcut)
	printf "\"text\":{\"copy\":\"%s\",\"largetype\":\"%s\"},", escape(copy), escape(arg)
	printf "\"quicklookurl\":\"https://tmuxcheatsheet.com\"}"
}

END {
	if (count == 0) {
		printf "{\"uid\":\"no-results\","
		printf "\"title\":\"No tmux commands found\","
		printf "\"subtitle\":\"Try a broader query (e.g. split, session, pane, copy)\","
		printf "\"valid\":false}"
	}
	printf "]}"
}

function escape(s) {
	gsub(/\\/, "\\\\", s)
	gsub(/"/, "\\\"", s)
	gsub(/\t/, " ", s)
	gsub(/\n/, "\\n", s)
	return s
}
' "${DATA_FILE}"
