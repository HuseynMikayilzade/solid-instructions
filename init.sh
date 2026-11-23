#!/usr/bin/env bash
set -euo pipefail

# Initializes a SOLIDWORKS Human-Like CAD workspace on macOS or Linux.
# Note: SOLIDWORKS 2026 Desktop/COM is Windows-only, so macOS/Linux operates in
# Priority 2 (standalone VBA .bas macro generation) or Priority 3 (manual guide)
# unless run inside a Windows VM.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="solidworks-photo-to-cad"
INIT_SKILL_NAME="solidworks-init"

TARGET_WORKSPACE=""
GLOBAL_INSTALL=0
FORCE=0
DRY_RUN=0

usage() {
  cat <<EOF
Usage: ./init.sh [--target <path>] [--global] [--force] [--dry-run]

Options:
  --target <path>   Initialize a separate project folder with rules, skills, and commands
  --global          Install rules, skills, and slash commands globally (~/.gemini, ~/.claude, ~/.codex)
  --force           Overwrite existing AGENTS.md / CLAUDE.md / GEMINI.md files
  --dry-run         Preview actions without writing files
  -h, --help        Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_WORKSPACE="${2:-}"
      shift 2
      ;;
    --global)
      GLOBAL_INSTALL=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

copy_safe() {
  local src="$1"
  local dst="$2"
  local allow_overwrite="$3"
  if [[ -e "$dst" && "$allow_overwrite" -eq 0 ]]; then
    echo "[SKIP] Existing file preserved (use --force to overwrite): $dst"
    return 0
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY-RUN] Copy $src -> $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  echo "[OK] $dst"
}

copy_refs() {
  local dst_refs="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY-RUN] Copy references -> $dst_refs"
    return 0
  fi
  mkdir -p "$dst_refs"
  cp -R "$SCRIPT_DIR/.agents/skills/$SKILL_NAME/references/"* "$dst_refs/"
  echo "[OK] References copied to $dst_refs"
}

echo "=== SOLIDWORKS CAD Agent Init (macOS / Linux) ==="

CHECK_ROOT="$SCRIPT_DIR"

if [[ -n "$TARGET_WORKSPACE" ]]; then
  echo "Initializing target workspace: $TARGET_WORKSPACE"
  CHECK_ROOT="$TARGET_WORKSPACE"
  copy_safe "$SCRIPT_DIR/AGENTS.md" "$TARGET_WORKSPACE/AGENTS.md" "$FORCE"
  copy_safe "$SCRIPT_DIR/CLAUDE.md" "$TARGET_WORKSPACE/CLAUDE.md" "$FORCE"
  copy_safe "$SCRIPT_DIR/GEMINI.md" "$TARGET_WORKSPACE/GEMINI.md" "$FORCE"
  copy_safe "$SCRIPT_DIR/init.sh" "$TARGET_WORKSPACE/init.sh" 1
  if [[ "$DRY_RUN" -eq 0 ]]; then
    chmod +x "$TARGET_WORKSPACE/init.sh"
    mkdir -p "$TARGET_WORKSPACE/outputs" "$TARGET_WORKSPACE/sources"
    if [[ -f "$SCRIPT_DIR/sources/CAD-CAE-CAM-Serbest-Ish-2026.docx" ]]; then
      cp "$SCRIPT_DIR/sources/CAD-CAE-CAM-Serbest-Ish-2026.docx" "$TARGET_WORKSPACE/sources/"
    fi
  fi
  copy_safe "$SCRIPT_DIR/.agents/skills/$SKILL_NAME/SKILL.md" "$TARGET_WORKSPACE/.agents/skills/$SKILL_NAME/SKILL.md" 1
  copy_refs "$TARGET_WORKSPACE/.agents/skills/$SKILL_NAME/references"
  copy_safe "$SCRIPT_DIR/.agents/skills/$INIT_SKILL_NAME/SKILL.md" "$TARGET_WORKSPACE/.agents/skills/$INIT_SKILL_NAME/SKILL.md" 1
  copy_safe "$SCRIPT_DIR/.claude/skills/$SKILL_NAME/SKILL.md" "$TARGET_WORKSPACE/.claude/skills/$SKILL_NAME/SKILL.md" 1
  copy_safe "$SCRIPT_DIR/.gemini/skills/$SKILL_NAME/SKILL.md" "$TARGET_WORKSPACE/.gemini/skills/$SKILL_NAME/SKILL.md" 1
  for f in solidworks-init.md solidworks-cad.md; do
    copy_safe "$SCRIPT_DIR/.claude/commands/$f" "$TARGET_WORKSPACE/.claude/commands/$f" 1
  done
  for f in solidworks-init.toml solidworks-cad.toml; do
    copy_safe "$SCRIPT_DIR/.gemini/commands/$f" "$TARGET_WORKSPACE/.gemini/commands/$f" 1
  done
else
  if [[ "$DRY_RUN" -eq 0 ]]; then
    mkdir -p "$SCRIPT_DIR/outputs" "$SCRIPT_DIR/sources"
  fi
fi

if [[ "$GLOBAL_INSTALL" -eq 1 ]]; then
  echo "Installing globally across AI platforms..."
  # Antigravity
  copy_safe "$SCRIPT_DIR/.agents/skills/$SKILL_NAME/SKILL.md" "$HOME/.gemini/config/skills/$SKILL_NAME/SKILL.md" 1
  copy_refs "$HOME/.gemini/config/skills/$SKILL_NAME/references"
  copy_safe "$SCRIPT_DIR/.agents/skills/$INIT_SKILL_NAME/SKILL.md" "$HOME/.gemini/config/skills/$INIT_SKILL_NAME/SKILL.md" 1
  copy_safe "$SCRIPT_DIR/AGENTS.md" "$HOME/.gemini/config/rules/solidworks-cad-agent.md" "$FORCE"
  # Codex
  copy_safe "$SCRIPT_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md" "$FORCE"
  copy_safe "$SCRIPT_DIR/.agents/skills/$SKILL_NAME/SKILL.md" "$HOME/.codex/skills/$SKILL_NAME/SKILL.md" 1
  copy_refs "$HOME/.codex/skills/$SKILL_NAME/references"
  copy_safe "$SCRIPT_DIR/.agents/skills/$INIT_SKILL_NAME/SKILL.md" "$HOME/.codex/skills/$INIT_SKILL_NAME/SKILL.md" 1
  # Claude Code
  copy_safe "$SCRIPT_DIR/AGENTS.md" "$HOME/.claude/CLAUDE.md" "$FORCE"
  copy_safe "$SCRIPT_DIR/.claude/skills/$SKILL_NAME/SKILL.md" "$HOME/.claude/skills/$SKILL_NAME/SKILL.md" 1
  copy_refs "$HOME/.claude/skills/$SKILL_NAME/references"
  for f in solidworks-init.md solidworks-cad.md; do
    copy_safe "$SCRIPT_DIR/.claude/commands/$f" "$HOME/.claude/commands/$f" 1
  done
  # Gemini CLI
  copy_safe "$SCRIPT_DIR/AGENTS.md" "$HOME/.gemini/GEMINI.md" "$FORCE"
  copy_safe "$SCRIPT_DIR/.gemini/skills/$SKILL_NAME/SKILL.md" "$HOME/.gemini/skills/$SKILL_NAME/SKILL.md" 1
  copy_refs "$HOME/.gemini/skills/$SKILL_NAME/references"
  for f in solidworks-init.toml solidworks-cad.toml; do
    copy_safe "$SCRIPT_DIR/.gemini/commands/$f" "$HOME/.gemini/commands/$f" 1
  done
fi

echo ""
echo "--- Environment Readiness Check ($(uname -s)) ---"
echo "  [OS]   Platform                    : $(uname -s) ($(uname -m))"
echo "  [COM]  SOLIDWORKS Desktop / COM    : Not native on macOS/Linux (Windows / Parallels VM only)"
if [[ -f "$CHECK_ROOT/sources/CAD-CAE-CAM-Serbest-Ish-2026.docx" ]]; then
  echo "  [DOC]  Instructor Guide (.docx)    : OK"
else
  echo "  [DOC]  Instructor Guide (.docx)    : Optional (not in sources/)"
fi
echo ""
echo "Active Execution Mode : Priority 2 (Standalone SOLIDWORKS 2026 VBA .bas Macro + Manual Guide)"
echo "Guidelines Loaded From: $CHECK_ROOT/AGENTS.md"
echo "Init complete."
