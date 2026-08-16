#!/bin/bash
# Session-start hook: surfaces current project state at the top of every session.
# Derives the project root from this script's own location — no hardcoded paths.

PROJECT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PROJECT

# --- Shared memory sync (pull) ---
# Copies the canonical "about Clark" memory files (background, engagement
# style, feedback patterns -- not project-specific facts) into this
# project's own memory namespace, and splices their index entries into
# this project's MEMORY.md between marker comments. Silently does nothing
# if the canonical store isn't reachable, so a missing/moved ProjectStarter
# never breaks session start.
SHARED_MEMORY_DIR="$HOME/Scholarship/ProjectStarter/SharedMemory"
if [ -d "$SHARED_MEMORY_DIR" ]; then
  MEMORY_KEY=$(echo "$PROJECT" | tr '/' '-')
  LOCAL_MEMORY_DIR="$HOME/.claude/projects/${MEMORY_KEY}/memory"
  mkdir -p "$LOCAL_MEMORY_DIR"
  for f in "$SHARED_MEMORY_DIR"/*.md; do
    base="$(basename "$f")"
    [ "$base" = "MEMORY_BLOCK.md" ] && continue
    cp "$f" "$LOCAL_MEMORY_DIR/$base" 2>/dev/null
  done
  LOCAL_MEMORY_INDEX="$LOCAL_MEMORY_DIR/MEMORY.md"
  [ -f "$LOCAL_MEMORY_INDEX" ] || echo "# Memory Index" > "$LOCAL_MEMORY_INDEX"
  python3 - "$LOCAL_MEMORY_INDEX" "$SHARED_MEMORY_DIR/MEMORY_BLOCK.md" << 'SYNCEOF' 2>/dev/null
import sys
local_path, block_path = sys.argv[1], sys.argv[2]
start, end = "<!-- SHARED MEMORY START -->", "<!-- SHARED MEMORY END -->"
local = open(local_path).read()
block = open(block_path).read().strip()
section = start + "\n" + block + "\n" + end
if start in local and end in local:
    pre = local.split(start)[0]
    post = local.split(end)[1]
    new_local = pre + section + post
else:
    lines = local.split("\n", 1)
    header = lines[0] if lines else "# Memory Index"
    rest = lines[1] if len(lines) > 1 else ""
    new_local = header + "\n\n" + section + "\n" + rest
open(local_path, "w").write(new_local)
SYNCEOF
fi

echo "======================================================"
echo "SESSION START CONTEXT"
echo "======================================================"
echo ""
echo "--- TASKLOG: Last 4 Sessions ---"
python3 << 'PYEOF'
import re, os
path = os.environ["PROJECT"] + "/TaskLog.md"
try:
    content = open(path).read()
    sessions = re.split(r'(?=^## Session)', content, flags=re.MULTILINE)
    sessions = [s for s in sessions if s.strip().startswith('## Session')]
    for s in sessions[:4]:
        print(s.rstrip())
        print()
except FileNotFoundError:
    print("(TaskLog.md not found)")
PYEOF

echo ""
echo "--- CLARK HOMEWORK (full) ---"
cat "$PROJECT/Clark_Homework.md" 2>/dev/null || echo "(Clark_Homework.md not found)"
echo ""
echo "--- AVAILABLE TOOLS (Tools/) ---"
ls "$PROJECT/Tools/" 2>/dev/null || echo "(Tools/ not found)"
echo ""
echo "======================================================"
