# tmux Cheat Sheet (Alfred Workflow)

Quickly look up tmux commands, key bindings, and practical examples directly from Alfred.

## Install

Download `alfred-tmux-cheat-sheet.alfredworkflow` from the [latest release](https://git.felixfoertsch.de/felixfoertsch/alfred-tmux-cheat-sheet/releases/latest) and open it — Alfred imports it automatically.

## Usage

1. Open Alfred and type `tmux` followed by your query.
2. Results are ranked by how commonly they are needed.
3. Press **Enter** to copy the result to clipboard.
4. Press **Cmd+L** for a large type view.

### Examples

| Query | Finds |
|---|---|
| `tmux new session name` | `tmux new -s mysession` |
| `tmux split` | Key bindings (Ctrl+b %, Ctrl+b ") and commands |
| `tmux attach` | All ways to attach to a session |
| `tmux copy` | Copy mode shortcuts and buffer commands |
| `tmux mouse` | `tmux set -g mouse on` |

## Configuration

Open **Alfred → Workflows → tmux Cheat Sheet → Configure Workflow** to change the prefix key (default: `Ctrl+b`).

## Development

**Data sources:**
- **Key bindings** are parsed from your local `man tmux` via `bash scripts/parse_manual.sh`.
- **Practical examples** are curated in `data/examples.tsv` — add your own by appending a line: `command-name\tdescription\ttmux command`.
- **Tier ordering** controls result priority in `data/tiers.tsv` (1 = essential, 4 = rare).

**Regenerate** the cheat sheet after a tmux update: `bash scripts/parse_manual.sh`

**Run tests:** `bash tests/test_tmux_search.sh`

**Build locally:** `bash build/build_workflow.sh`
