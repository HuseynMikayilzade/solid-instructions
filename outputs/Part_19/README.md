# Part_19 — Free Work No. 19

- **Latest version:** `v006`
- **Status:** `COMPLETED`
- **Version history:**
  - `v001`: Initial SOLIDWORKS 2026 reconstruction (`Part_19.SLDPRT` / `Part_19.STEP` in workspace root).
  - `v002`: Added `Plane1` + `Mirror1` for rear lug and default SOLIDWORKS naming.
  - `v003`: Clean symmetry-centered rebuild on `Right Plane` (`X = 0`), mirroring all symmetric saddle halves (`Boss-Extrude1` + `Boss-Extrude2` + `Boss-Extrude3`) via `Mirror1`, API-verified core symmetry (`CoM_X = 0.000024 mm`), and non-overlapping asymmetric left wing (`Boss-Extrude4`, `Boss-Extrude5`, `Cut-Extrude3`).
  - `v004`: Progressive feature-by-feature rebuild (`120 = 20 + 80 + 20 mm`) mirroring the complete 5-feature left side-support assembly (`Boss-Extrude3`, `Boss-Extrude4`, `Boss-Extrude5`, `Cut-Extrude1`, `Cut-Extrude2`) across `Right Plane` (`X = 0`) via `Mirror1` (`1` solid body, `CoM_X = 0.000016 mm`).
  - `v005`: Fresh from-scratch solid-first rebuild strictly matching visible drawing geometry (`100 × 70 × 70 mm`: `80` mm central cradle/base + `20` mm left buttress/wing + `30 × 15` mm right rear lug + `Ø60` bore + `40 × 40` through-pocket; `1` solid body, `170.240 cm³`, verified SLDPRT reopen & STEP import).
  - `v006`: Symmetric from-scratch rebuild (`120 × 70 × 70 mm`, `20 + 80 + 20 mm`) mirroring the complete left side-support assembly (`Boss-Extrude3` base wing + `Boss-Extrude4` sloped buttress & raised wall) across `Right Plane` (`X = 0`) via native `Mirror1` (`1` solid body, `198.331 cm³`, `CoM_X = 0.000000 mm`, verified SLDPRT reopen & STEP import).
