---
name: solidworks-photo-to-cad
description: >-
  Reconstructs mechanical parts from user-provided photographs or multi-view images into parametric, human-like SOLIDWORKS 2026 3D models. Use when the user uploads part photos, asks to reverse-engineer or model a physical object in SOLIDWORKS, or needs a SOLIDWORKS VBA macro or manual modeling workflow from reference images.
---

# SOLIDWORKS Photo-to-CAD Workflow

Turn one or more part photographs or drawings into an editable, parametric, visually accurate SOLIDWORKS 2026 solid model (`Part_XX_vNNN.SLDPRT` + `Part_XX_vNNN.STEP`) following the methodology hierarchy and rules in `AGENTS.md`.

## Step-by-Step Execution

1. **Analyze Views, Verticality & Multi-Level Symmetry (`./references/photo-analysis-and-dimensions.md`)**
   - Prioritize explicit dimension annotations and orthographic views over isometric/perspective estimation; never silently alter source geometry.
   - Protect straight vertical columns, walls, and raised supports from perspective-induced inward slopes or unjustified bevels/cuts.
   - Run the **multi-level symmetry analysis** from `AGENTS.md` Section 3: list the central geometry, complete left/right structural groups (buttresses, sloped supports, raised sections, columns, extensions, bevels, associated profiles/cuts), and genuinely asymmetric exclusions, classifying symmetry as `CONFIRMED`, `INFERRED`, or `UNCERTAIN`.
   - Build a classified dimension map (`CONFIRMED`, `CALCULATED`, `ESTIMATED`, `ASSUMED`, `UNKNOWN`).

2. **Complete Mandatory 16-Item Pre-Modeling Plan (`./references/sketch-and-feature-standards.md`)**
   - Follow the 3-tier hierarchy in `AGENTS.md` Section 1 (`DOCUMENTED` instructor workflow → `OBSERVED PATTERN` → `NOT SPECIFIED` supplemental SOLIDWORKS practices).
   - Formulate all 16 planning items from `AGENTS.md` Section 4 before creating any geometry or VBA code, explaining major solid shapes, why each is separate or combined, cutting strategy, and mirror/pattern choices.
   - Balance feature granularity: avoid both **excessive fragmentation** and **one giant mega-sketch**; prefer substantial solid sections refined by cuts, keep `Merge result` enabled for single bodies, keep default SOLIDWORKS names (`Sketch1`, `Boss-Extrude1`, `Cut-Extrude1`, `Mirror1`), and never use surface patches or primitive stacking.

3. **Execute by Strict Priority**
   - **Priority 1 — Direct SOLIDWORKS Desktop / Live COM (`./references/desktop-workflow.md`):** Use when desktop GUI or live SOLIDWORKS COM (`SldWorks.Application` + C# `csc.exe` / Interop DLLs) is available. Apply `Plain Carbon Steel` + `Shaded With Edges` (Tier 3) when no custom appearance is specified.
   - **Priority 2 — Complete VBA Macro Fallback (`./references/vba-api-fallback.md`, `./references/vba-template.bas`):** Output a complete, standalone `Option Explicit` SOLIDWORKS 2026 VBA module with SI meters/radians, sketch relations, `AddDimension2`, error handling, rebuild, and dual `.SLDPRT` + `.STEP` export.
   - **Priority 3 — Quick Manual Modeling Guide:** Shortest step-by-step SOLIDWORKS procedure if automation cannot reliably construct the part.

4. **Verify & Recover (`./references/verification-and-recovery.md`)**
   - Verify `ForceRebuild3`, solid body count, bounding box, mass/volume, **physical left/right structural symmetry** (presence of a `Mirror` feature alone is not proof), **straight vertical column/wall geometry**, and multi-view visual alignment.
   - Diagnose and fix root-cause sketch/feature failures without falling back to primitive stacking or surface mimicry.

5. **Save Versioned Outputs & Deliver Concise Report**
   - Inspect existing `outputs/Part_XX/` versions without overwriting prior work, save `Part_XX_vNNN.SLDPRT` and `Part_XX_vNNN.STEP` into `outputs/Part_XX/vNNN/`, update lightweight `outputs/Part_XX/README.md`, and report strictly per `AGENTS.md` Sections 6–7.
