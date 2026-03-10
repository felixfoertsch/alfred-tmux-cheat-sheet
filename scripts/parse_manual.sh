#!/usr/bin/env bash
# Build the tmux cheat sheet TSV from curated examples + man page key bindings.
# Output format: name\tdescription\tcommand\tshortcut
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${SCRIPT_DIR}/../data/tmux_commands.tsv"
EXAMPLES="${SCRIPT_DIR}/../data/examples.tsv"
TIERS="${SCRIPT_DIR}/../data/tiers.tsv"

man tmux | col -b > /tmp/tmux_man_raw.txt

# Extract key bindings from man page, then append curated examples, then sort by tier
{
	# 1. Key bindings from the man page
	awk '
	/^DEFAULT KEY BINDINGS/ { in_keys=1; next }
	in_keys && /^[A-Z][A-Z ]/ && !/^DEFAULT/ { flush(); in_keys=0 }

	function flush() {
		if (cur_key != "" && cur_desc != "") {
			shortcut = "{prefix} " cur_key
			gsub(/C-/, "Ctrl+", shortcut)
			gsub(/M-/, "Alt+", shortcut)
			first = cur_desc
			sub(/\. .*/, ".", first)
			name = "key-" cur_key
			gsub(/[[:space:]]/, "-", name)
			printf "%s\t%s\t\t%s\n", name, first, shortcut
		}
		cur_key = ""
		cur_desc = ""
	}

	in_keys && /^\t/ && /[^ \t]/ {
		flush()
		line = $0
		gsub(/^[[:space:]]+/, "", line)
		n = match(line, /\t|  +/)
		if (n > 0) {
			cur_key = substr(line, 1, n-1)
			cur_desc = substr(line, n)
			gsub(/^[[:space:]]+/, "", cur_desc)
			gsub(/[[:space:]]+$/, "", cur_desc)
			gsub(/[[:space:]]+$/, "", cur_key)
		}
		next
	}
	in_keys && /^\t\t/ && cur_key != "" {
		line = $0
		gsub(/^[[:space:]]+/, "", line)
		gsub(/[[:space:]]+$/, "", line)
		cur_desc = cur_desc " " line
		next
	}

	END { flush() }
	' /tmp/tmux_man_raw.txt

	# 2. Curated examples (name\tdescription\tcommand, no shortcut)
	awk -F'\t' '{ printf "%s\t%s\t%s\t\n", $1, $2, $3 }' "${EXAMPLES}"

} | awk -F'\t' '
NR == FNR {
	tier[$1] = $2
	next
}
{
	split($1, parts, /[[:space:]]/)
	cmd = parts[1]
	t = (cmd in tier) ? tier[cmd] : 3
	print t "\t" $0
}
' "${TIERS}" - | sort -t$'\t' -k1,1n | cut -f2- > "${OUT}"

count="$(wc -l < "${OUT}" | tr -d ' ')"
echo "Wrote ${count} entries to ${OUT}"
