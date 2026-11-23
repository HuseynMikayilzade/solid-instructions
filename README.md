# SOLIDWORKS Human-Like CAD Agent Instruction System

A cross-platform, reusable engineering rule and skill package that teaches AI agents (Antigravity, Claude Code, OpenAI Codex CLI, Gemini CLI, and compatible agents) to reconstruct mechanical parts from photographs into parametric, editable **SOLIDWORKS 2026** models using a human CAD engineer's sketch-first, feature-based workflow.

> **Target CAD Version:** This package explicitly targets **SOLIDWORKS 2026** (desktop workflow, VBA macro standards, template fallback paths, and modern non-obsolete API patterns).

---

## Repository Structure

```text
SolidWorks/
├── AGENTS.md                                      # Canonical universal CAD rules & instructor methodology hierarchy
├── CLAUDE.md                                      # Claude Code entry (@./AGENTS.md)
├── GEMINI.md                                      # Gemini CLI / Antigravity entry (@./AGENTS.md)
├── README.md                                      # Setup & platform placement guide
├── init.cmd                                       # One-command Windows PC / workspace initializer
├── .agents/skills/
│   ├── solidworks-init/
│   │   └── SKILL.md                               # Portable workspace/PC init skill
│   └── solidworks-photo-to-cad/
│       ├── SKILL.md                               # Canonical Photo-to-CAD skill (Antigravity & Codex)
│       └── references/
│           ├── photo-analysis-and-dimensions.md   # View priority, verticality protection, symmetry groups, dimension tags
│           ├── sketch-and-feature-standards.md    # Instructor patterns, solid-first granularity, 16-item planning, tree order
│           ├── desktop-workflow.md                # Priority 1: interactive SOLIDWORKS / live C# COM workflow
│           ├── vba-api-fallback.md                # Priority 2: SOLIDWORKS 2026 VBA API standards & signatures
│           ├── vba-template.bas                   # Reusable Option Explicit VBA macro scaffold
│           └── verification-and-recovery.md       # Physical symmetry, verticality, visual + geometric checks, recovery
├── .claude/
│   ├── commands/
│   │   ├── solidworks-init.md                     # /solidworks-init command (Claude Code)
│   │   └── solidworks-cad.md                      # /solidworks-cad command (Claude Code)
│   └── skills/solidworks-photo-to-cad/
│       └── SKILL.md                               # Claude Code skill entrypoint
├── .gemini/
│   ├── commands/
│   │   ├── solidworks-init.toml                   # /solidworks-init command (Gemini CLI)
│   │   └── solidworks-cad.toml                    # /solidworks-cad command (Gemini CLI)
│   └── skills/solidworks-photo-to-cad/
│       └── SKILL.md                               # Gemini CLI skill entrypoint
├── outputs/                                       # Versioned CAD task outputs (created per CAD task)
│   └── Part_XX/
│       ├── README.md                              # Lightweight task status & latest version summary
│       └── vNNN/
│           ├── Part_XX_vNNN.SLDPRT                # Mandatory native SOLIDWORKS 2026 part
│           └── Part_XX_vNNN.STEP                  # Mandatory exported STEP model
├── sources/
│   └── CAD-CAE-CAM-Serbest-Ish-2026.docx          # Instructor methodology & task source
└── scripts/
    ├── init-solidworks-workspace.ps1              # Environment checker & workspace/global init script
    └── install-solidworks-agent.ps1               # Windows installer for global or workspace deployment
```

---

## Output & Versioning Convention

- Each CAD modeling task writes **only** two mandatory deliverables to `outputs/Part_XX/vNNN/`:
  - `Part_XX_vNNN.SLDPRT`
  - `Part_XX_vNNN.STEP`
- Revisions increment sequentially (`v001`, `v002`, ...) without overwriting prior completed versions.
- Each task maintains a lightweight `outputs/Part_XX/README.md` (task name, latest version, status, brief change summary).
- Screenshots, VBA macros, scripts, and logs are optional and kept out of `outputs/Part_XX/vNNN/`.

---

## Where Files Go per AI Platform

### 1. In This Workspace (Ready Out of the Box)
If you open `c:\Users\User\Desktop\SolidWorks` directly, every supported agent discovers its entry files automatically:

| AI Platform | Rule File Loaded Automatically | Skill Discovered Automatically |
| :--- | :--- | :--- |
| **Antigravity** | `AGENTS.md` / `GEMINI.md` | `.agents/skills/solidworks-photo-to-cad/SKILL.md` |
| **OpenAI Codex CLI** | `AGENTS.md` | `.agents/skills/solidworks-photo-to-cad/SKILL.md` |
| **Claude Code** | `CLAUDE.md` (imports `@./AGENTS.md`) | `.claude/skills/solidworks-photo-to-cad/SKILL.md` |
| **Gemini CLI** | `GEMINI.md` (imports `@./AGENTS.md`) | `.gemini/skills/solidworks-photo-to-cad/SKILL.md` |
| **Other Agents** | Copy/paste `AGENTS.md` as system/project prompt | Attach `SKILL.md` + needed `references/` files |

### 2. Quick Init on Any New PC (Recommended)

After copying or cloning this folder to another Windows PC, run the one-step initializer:

```powershell
# Check SOLIDWORKS 2026 COM, C# compiler, templates & materials on this PC:
.\init.cmd

# Initialize a brand-new project folder on that PC with all rules, skills, commands, and sources/:
.\init.cmd -TargetWorkspace "D:\Projects\MyCADRepo"

# Install rules, skills, and slash commands globally for Antigravity, Codex, Claude Code, and Gemini CLI:
.\init.cmd -Global
```

Inside **Claude Code**, **Gemini CLI**, **Codex**, or **Antigravity**, you can also run **`/solidworks-init`** (or invoke the `solidworks-init` skill) to verify the PC environment and enforce `AGENTS.md` guidelines, and **`/solidworks-cad <part>`** to model a part directly.

### 3. Installing Globally or Into Another Project (`install-solidworks-agent.ps1`)

Preview first with `-DryRun`:
```powershell
.\scripts\install-solidworks-agent.ps1 -Platform all -DryRun
```

Install into another project workspace:
```powershell
.\scripts\install-solidworks-agent.ps1 -Platform workspace -TargetWorkspace "D:\Projects\MyCADRepo"
```

Install globally for a specific platform (`antigravity`, `codex`, `claude`, `gemini`, or `all`):
```powershell
.\scripts\install-solidworks-agent.ps1 -Platform all
```
*(Existing global `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md` files are preserved unless `-Force` is passed. Global skill folders receive a self-contained copy of `references/` automatically.)*

Global destinations used by the installer:
- **Antigravity:** `~/.gemini/config/rules/solidworks-cad-agent.md` + `~/.gemini/config/skills/solidworks-photo-to-cad/`
- **Codex CLI:** `~/.codex/AGENTS.md` + `~/.codex/skills/solidworks-photo-to-cad/`
- **Claude Code:** `~/.claude/CLAUDE.md` + `~/.claude/skills/solidworks-photo-to-cad/`
- **Gemini CLI:** `~/.gemini/GEMINI.md` + `~/.gemini/skills/solidworks-photo-to-cad/`

---

## Verifying Setup

- **Antigravity:** Open this workspace and upload a part photo; check that `solidworks-photo-to-cad` appears in available skills.
- **Claude Code:** Run `/context` to verify `AGENTS.md` imported via `CLAUDE.md`, and `/solidworks-photo-to-cad` to verify skill loading.
- **Gemini CLI:** Run `/memory show` to confirm `AGENTS.md` compiled into active context via `GEMINI.md`.
- **Codex CLI:** Start Codex inside this workspace; `AGENTS.md` and `.agents/skills/solidworks-photo-to-cad` load automatically.
