#!/usr/bin/env bash
# bundle.sh — copy engine scripts AND plugin content from raven-core into platform repos
# Run this after any engine change before releasing a new version
#
# Usage: bash bundle.sh [--dry-run]

set -e

DRY_RUN=false
[[ "$1" == "--dry-run" ]] && DRY_RUN=true

CORE_DIR="$(cd "$(dirname "$0")" && pwd)"
PLATFORM_DIR="$(dirname "$CORE_DIR")"
CURRENT_VERSION="$(cat "$CORE_DIR/VERSION" 2>/dev/null || echo "unknown")"

ENGINE_SCRIPTS=("cve-check.py" "secret-scan.py" "audit-log.py" "emit-violation.py" "db-guard.py")
MCP_SCRIPT="server.py"
ANDIE_SRC="${HOME}/.claude/skills/andie/SKILL.md"
TOOLS_SRC="${HOME}/.claude/skills/tools-landscape"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Raven Core — Bundle Engine Scripts"
echo "  Version: $CURRENT_VERSION"
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
  # Write version stamp to parent .raven/ directory
  if [[ "$DRY_RUN" == "false" ]]; then
    RAVEN_DIR="$(dirname "$DEST")/.raven"
    mkdir -p "$RAVEN_DIR"
    echo "$CURRENT_VERSION" > "$RAVEN_DIR/raven_version"
    echo "  ✅ .raven/raven_version → $CURRENT_VERSION"
  fi
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

# Engine scripts — monorepo targets
bundle_scripts "raven (claude)"   "$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/.claude/scripts"
bundle_scripts "raven (codex)"    "$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/codex/scripts"
bundle_scripts "raven-action"     "$PLATFORM_DIR/raven-action/scripts"

echo ""

# MCP server
bundle_mcp "raven (claude)"  "$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/mcp"
bundle_mcp "raven (codex)"   "$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/codex/mcp"

echo ""

# Andie skill — sync from canonical ~/.claude/skills/andie/SKILL.md
echo "▶ Andie skill sync"
ANDIE_TARGETS=(
  "$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/core/skills/andie/SKILL.md"
  "$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/guard/guard/skills/andie/SKILL.md"
)
if [[ ! -f "$ANDIE_SRC" ]]; then
  echo "  ⚠️  Andie SKILL.md not found at $ANDIE_SRC — skipping"
else
  for DEST in "${ANDIE_TARGETS[@]}"; do
    if [[ "$DRY_RUN" == "false" ]]; then
      mkdir -p "$(dirname "$DEST")"
      cp "$ANDIE_SRC" "$DEST"
    fi
    echo "  ✅ $(dirname "$DEST" | sed "s|$PLATFORM_DIR/||")"
  done
fi

# Tools landscape skill — sync full directory from ~/.claude/skills/tools-landscape/
echo "▶ Tools landscape skill sync"
TOOLS_TARGETS=(
  "$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/core/skills/tools-landscape"
  "$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/guard/guard/skills/tools-landscape"
)
if [[ ! -d "$TOOLS_SRC" ]]; then
  echo "  ⚠️  tools-landscape not found at $TOOLS_SRC — skipping"
else
  for DEST in "${TOOLS_TARGETS[@]}"; do
    if [[ "$DRY_RUN" == "false" ]]; then
      mkdir -p "$DEST"
      cp "$TOOLS_SRC/SKILL.md" "$DEST/SKILL.md"
      cp "$TOOLS_SRC/registry.json" "$DEST/registry.json"
    fi
    echo "  ✅ $(echo "$DEST" | sed "s|$PLATFORM_DIR/||") (SKILL.md + registry.json)"
  done
fi

# Plugin content — sync skills/agents/commands from SHAY-ROLLS into raven-core (plugin package)
echo "▶ Plugin content sync → raven-core"
PLUGIN_SRC="$PLATFORM_DIR/SHAY-ROLLS/CLAUDE/RAVEN/core"
PLUGIN_DST="$CORE_DIR"

if [[ -d "$PLUGIN_SRC/skills" ]]; then
  for skill_dir in "$PLUGIN_SRC/skills"/*/; do
    skill_name="$(basename "$skill_dir")"
    if [[ "$DRY_RUN" == "false" ]]; then
      mkdir -p "$PLUGIN_DST/skills/$skill_name"
      [[ -f "$skill_dir/SKILL.md" ]] && cp "$skill_dir/SKILL.md" "$PLUGIN_DST/skills/$skill_name/SKILL.md"
      if [[ -d "$skill_dir/rules" ]]; then
        mkdir -p "$PLUGIN_DST/skills/$skill_name/rules"
        cp "$skill_dir/rules/"*.md "$PLUGIN_DST/skills/$skill_name/rules/" 2>/dev/null || true
      fi
    fi
    echo "  ✅ skills/$skill_name"
  done
fi

if [[ "$DRY_RUN" == "false" ]]; then
  mkdir -p "$PLUGIN_DST/agents"
  cp "$PLUGIN_SRC/agents/"*.md "$PLUGIN_DST/agents/" 2>/dev/null || true
  mkdir -p "$PLUGIN_DST/commands"
  cp "$PLUGIN_SRC/commands/"*.md "$PLUGIN_DST/commands/" 2>/dev/null || true
fi
echo "  ✅ agents/ ($(ls "$PLUGIN_DST/agents/" 2>/dev/null | wc -l | tr -d ' ') files)"
echo "  ✅ commands/ ($(ls "$PLUGIN_DST/commands/" 2>/dev/null | wc -l | tr -d ' ') files)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done. Commit each platform repo."
echo "  Install plugin: claude plugin install giggsoinc/raven"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
