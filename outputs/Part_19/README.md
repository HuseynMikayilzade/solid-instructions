# Part_19 — Free Work No. 19

- **Latest version:** `v004`
- **Status:** `COMPLETED`
- **Version history:**
  - `v001`: Initial SOLIDWORKS 2026 reconstruction (`Part_19.SLDPRT` / `Part_19.STEP` in workspace root).
  - `v002`: Added `Plane1` + `Mirror1` for rear lug and default SOLIDWORKS naming.
  - `v003`: Clean symmetry-centered rebuild on `Right Plane` (`X = 0`), mirroring all symmetric saddle halves (`Boss-Extrude1` + `Boss-Extrude2` + `Boss-Extrude3`) via `Mirror1`, API-verified core symmetry (`CoM_X = 0.000024 mm`), and non-overlapping asymmetric left wing (`Boss-Extrude4`, `Boss-Extrude5`, `Cut-Extrude3`).
  - `v004`: Progressive feature-by-feature rebuild (`120 = 20 + 80 + 20 mm`) mirroring the complete 5-feature left side-support assembly (`Boss-Extrude3`, `Boss-Extrude4`, `Boss-Extrude5`, `Cut-Extrude1`, `Cut-Extrude2`) across `Right Plane` (`X = 0`) via `Mirror1` (`1` solid body, `CoM_X = 0.000016 mm`).
