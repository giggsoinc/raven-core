#!/usr/bin/env bash
# bundle.sh — copy engine scripts from raven-core into each platform repo
# Run this after any engine change before releasing a new version
#
# Usage: bash bundle.sh [--dry-run]

set -e

DRY_RUN=false
[[ "$1" == "--dry-run" ]] && DRY_RUN=true

CORE_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM_DIR="$(dirname "$CORE_DIR")"

ENGINE_SCRIPTS=("cve-check.py" "secret-scan.py" "audit-log.py" "emit-violation.py")
MCP_SCRIPT="server.py"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Raven Core — Bundle Engine Scripts"
[[ "$DRY_RUN" == "true" ]] && echo "  DRY RUN — no files written"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

bundle_scripts() {
  local REPO="$1"
  local DEST="$2"
  echo "▶ $REPO → $DEST"
  [[ "$DRY_RUN" == "false" ]] && mkdir -p "$DEST"
  for SCRIPT in "${ENGINE_SCRIPTS[@]}"; do
    SRC="$CORE_DIR/$SCRIPT"
    if [[ -f "$SRC" ]]; then
      if [[ "$DRY_RUN" == "false" ]]; then
        cp "$SRC" "$DEST/$SCRIPT"
        chmod +x "$DEST/$SCRIPT"
      fi
      echo "  ✅ $SCRIPT"
    else
      echo "  ❌ $SCRIPT — not found in raven-core"
    fi
  done
}

bundle_mcp() {
  local REPO="$1"
  local DEST="$2"
  echo "▶ $REPO (MCP server) → $DEST"
  if [[ "$DRY_RUN" == "false" ]]; then
    mkdir -p "$DEST"
    cp "$CORE_DIR/$MCP_SCRIPT" "$DEST/$MCP_SCRIPT"
    chmod +x "$DEST/$MCP_SCRIPT"
  fi
  echo "  ✅ $MCP_SCRIPT"
}

# Engine scripts
bundle_scripts "raven"            "$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/.claude/scripts"
bundle_scripts "raven-codex"      "$PLATFORM_DIR/raven-codex/scripts"
bundle_scripts "raven-action"     "$PLATFORM_DIR/raven-action/scripts"

echo ""

# MCP server
bundle_mcp "raven"       "$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/mcp"
bundle_mcp "raven-codex" "$PLATFORM_DIR/raven-codex/mcp"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done. Commit each platform repo."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
