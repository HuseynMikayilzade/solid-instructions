Initialize and verify the SOLIDWORKS Human-Like CAD environment for this workspace (or a target workspace passed in `$ARGUMENTS`).

1. On Windows run `.\init.cmd` (or `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\init-solidworks-workspace.ps1`); on macOS/Linux run `bash ./init.sh` (pass `-TargetWorkspace` / `--target` or `-Global` / `--global` if requested in `$ARGUMENTS`).
2. Read `AGENTS.md` and `.agents/skills/solidworks-photo-to-cad/SKILL.md` to confirm all rules and skill references are active.
3. Report the detected execution mode (`Priority 1: Live SOLIDWORKS COM + C#` vs `Priority 2: VBA Macro Fallback`), SOLIDWORKS template/materials status, and confirm readiness to model parts under `AGENTS.md`.
