---
name: solidworks-init
description: >-
  Initializes or verifies a SOLIDWORKS Human-Like CAD workspace on any PC so that
  AGENTS.md guidelines, skills, slash commands, SOLIDWORKS 2026 COM/C# automation,
  and outputs/Part_XX/vNNN versioning work immediately out of the box. Use when
  setting up a new PC/project, checking SOLIDWORKS readiness, or running /solidworks-init.
---

# SOLIDWORKS Workspace & PC Initialization (`init`)

Run this workflow when setting up a new PC, initializing a target project folder, or verifying SOLIDWORKS 2026 automation readiness before modeling.

## Steps

1. **Run the Portable Init Script:**
   - **Windows:**
     ```powershell
     .\init.cmd
     # Or initialize a new folder / install globally:
     .\init.cmd -TargetWorkspace "D:\Path\To\Project"
     .\init.cmd -Global
     ```
     *(If Windows blocks a downloaded ZIP script via Mark-of-the-Web, run `Unblock-File -Path .\init.cmd, .\scripts\*.ps1` or run `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\init-solidworks-workspace.ps1`.)*
   - **macOS / Linux (e.g., MacBook):**
     ```bash
     chmod +x ./init.sh && ./init.sh
     # Or initialize a new folder / install globally:
     ./init.sh --target "$HOME/Projects/MyCADRepo"
     ./init.sh --global
     ```
2. **Inspect Readiness Output:**
   - Confirm `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.agents/skills/solidworks-photo-to-cad/`, `outputs/`, and `sources/` are in place.
   - Check the reported execution mode:
     - **Priority 1 (`Live SOLIDWORKS COM + C# Automation`)**: `SldWorks.Application` ProgID + `api\redist\SolidWorks.Interop.*.dll` + `.NET csc.exe` + `Part.PRTDOT` are all present.
     - **Priority 2 (`VBA Macro Fallback`)**: SOLIDWORKS COM or `csc.exe` is missing on this machine; generate standalone `Option Explicit` `.bas` macros from `references/vba-template.bas`.
3. **Activate Modeling Guidelines:**
   - Summarize the verified environment status concisely to the user and state that all subsequent modeling tasks will follow `AGENTS.md` (instructor methodology hierarchy, 16-item pre-modeling plan, `Plain Carbon Steel` + `Shaded With Edges` Tier 3 visual standard, `outputs/Part_XX/vNNN/` deliverables).
