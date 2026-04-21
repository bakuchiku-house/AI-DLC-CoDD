#!/usr/bin/env bash
set -uo pipefail
# NOTE: -e (errexit) is intentionally omitted.
# Step 3 'codd hooks install' can fail on Windows with a symlink permission error (WinError 1314).
# With -e the entire script would abort silently; instead, each step handles errors individually.

# install-codd-pre-commit.sh
#
# Installs the CoDD pre-commit hook for the current project.
# Automatically executed by Claude Code at session start (SessionStart hook).
#
# Usage:
#   bash .claude/hooks/install-codd-pre-commit.sh
#
# What it does:
#   1. Checks that the 'codd' CLI is available on PATH
#   2. Checks if .git directory exists; if not, runs 'git init' automatically
#   3. Runs 'codd hooks install --path .' to install the pre-commit hook
#      (idempotent: safe to run multiple times)
#      On Windows, if symlink creation fails, prints guidance and exits cleanly
#
# NOTE on output: All messages use stdout (not stderr) so they remain visible
# when this script is called from Claude Code hooks with stderr suppressed.

# ── 1. Check that codd is available ───────────────────────────────────────────
if ! command -v codd &> /dev/null; then
    echo "ERROR: 'codd' command not found."
    echo ""
    echo "Please install CoDD before using this project:"
    echo "  pip install codd-dev"
    echo ""
    echo "After installation, restart Claude Code or run this script manually:"
    echo "  bash .claude/hooks/install-codd-pre-commit.sh"
    exit 1
fi

# ── 2. Ensure .git directory exists (initialize if absent) ────────────────────
if [ ! -d ".git" ]; then
    echo "INFO: No .git directory found. Initializing git repository..."
    git init
    echo "INFO: Git repository initialized at $(pwd)/.git"
fi

# ── 3. Install the pre-commit hook ────────────────────────────────────────────
if ! codd hooks install --path . 2>&1; then
    echo ""
    echo "INFO: codd hooks install did not complete (likely WinError 1314 on Windows)."
    echo "INFO: Trying Python copy fallback..."
    if python3 -c "
import importlib.util, os, shutil, sys
spec = importlib.util.find_spec('codd')
if not spec: sys.exit(1)
pkg_dir = os.path.dirname(spec.origin)
hook_src = os.path.join(pkg_dir, 'hooks', 'pre-commit')
if not os.path.exists(hook_src): sys.exit(1)
os.makedirs('.git/hooks', exist_ok=True)
shutil.copy2(hook_src, '.git/hooks/pre-commit')
os.chmod('.git/hooks/pre-commit', 0o755)
print('INFO: pre-commit hook installed via file copy (symlink not required).')
" 2>/dev/null; then
        : # copy succeeded
    else
        echo ""
        echo "INFO: Copy fallback also failed. To install the pre-commit hook manually:"
        echo "        1. Enable Developer Mode: Windows Settings -> Privacy & Security -> For Developers"
        echo "        2. OR run Claude Code as Administrator"
        echo "        3. OR run manually: codd hooks install --path ."
        echo ""
    fi
fi

exit 0
