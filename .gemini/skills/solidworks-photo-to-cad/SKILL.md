---
name: solidworks-photo-to-cad
description: >-
  Reconstructs mechanical parts from user-provided photographs or multi-view images into parametric, human-like SOLIDWORKS 2026 3D models. Use when the user uploads part photos, asks to reverse-engineer or model a physical object in SOLIDWORKS, or needs a SOLIDWORKS VBA macro or manual modeling workflow from reference images.
---

# SOLIDWORKS Photo-to-CAD Workflow (Gemini CLI)

Follow the core rules in `AGENTS.md` (loaded via `GEMINI.md`) and execute the canonical workflow in `.agents/skills/solidworks-photo-to-cad/SKILL.md`.

## Reference Module Resolution

Read only the modules needed for the current step. Look in `./references/` first (present when installed globally/standalone), otherwise read from `.agents/skills/solidworks-photo-to-cad/references/` in the workspace root:

1. `photo-analysis-and-dimensions.md` — View/orthographic priority, vertical column protection, multi-level symmetry grouping, and dimension tags (`CONFIRMED`, `CALCULATED`, `ESTIMATED`, `ASSUMED`, `UNKNOWN`).
2. `sketch-and-feature-standards.md` — Instructor methodology (`DOCUMENTED`/`OBSERVED PATTERN`/`NOT SPECIFIED`), solid-first balanced granularity, mandatory 16-item planning template, FeatureManager order, and anti-patterns.
3. `desktop-workflow.md` — Priority 1 direct SOLIDWORKS GUI / live COM workflow (only if desktop or COM tools are actually available).
4. `vba-api-fallback.md` and `vba-template.bas` — Priority 2 complete, executable SOLIDWORKS 2026 VBA macro fallback.
5. `verification-and-recovery.md` — Physical symmetry & verticality checks, multi-view comparison, error recovery, and honest verification reporting.

## Output Management & Format

Follow `AGENTS.md` Sections 4–7 for the mandatory 16-item pre-modeling plan, `outputs/Part_XX/vNNN/Part_XX_vNNN.SLDPRT` + `.STEP` deliverables, sequential versioning, lightweight `outputs/Part_XX/README.md`, optional artifacts, and strict `COMPLETED` / `PARTIAL` / `FAILED` rules.

Present every result in order:
`Part Analysis` → `Dimensions` → `Modeling Process` → `Result` → `Quick Guide` → `Verification`.
