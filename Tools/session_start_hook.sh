#!/bin/bash
# Session-start hook: surfaces current project state at the top of every session.
# Derives the project root from this script's own location — no hardcoded paths.

PROJECT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PROJECT

echo "======================================================"
echo "SESSION START CONTEXT — Aging Transitions Workshop"
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
