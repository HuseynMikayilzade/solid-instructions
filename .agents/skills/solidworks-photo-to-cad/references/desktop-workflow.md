# Interactive Desktop & Live SOLIDWORKS Workflow (Priority 1)

Use this workflow ONLY when your agent environment actually has desktop GUI interaction tools or live SOLIDWORKS COM/API execution capability on the host machine.

**Strict Honesty Rule:** Never pretend to click SOLIDWORKS UI elements or claim a `.SLDPRT` was built if you do not have live desktop/COM tool access or if SOLIDWORKS is unavailable. Immediately switch to Priority 2 (`./vba-api-fallback.md`).

**Pre-Execution Gate:** Complete the **mandatory 16-item pre-modeling plan** (`AGENTS.md` Section 4) *before* creating sketches or running COM commands.

---

## 1. Human-Like Interactive Desktop Sequence

When operating SOLIDWORKS 2026 interactively:

1. **Create Part Document:** Open SOLIDWORKS → `New` → `Part` (set units to `MMGS` or match confirmed drawing units, per `Sİ 1, 2, 4, 5`).
2. **Select Primary Plane:** Click `Front Plane`, `Top Plane`, or `Right Plane` per the 16-item plan.
3. **Enter Sketch Mode:** Click `Sketch`.
4. **Draw Substantial Primary Profile:** Anchor `Sketch1` to the **Origin**, use clean sketch tools (`Centerline`, `Line`, `Circle`, `Center Rectangle`, `Slot`, `Arc`, `Polygon`), and avoid both micro-fragmentation and cramming unrelated 3D features into one giant sketch.
5. **Apply Sketch Relations & Smart Dimensions:** Add `Horizontal`, `Vertical` (especially on straight walls/columns), `Symmetric`, `Concentric`, `Tangent`, `Equal` (`=`), `Coincident` relations, then `Smart Dimension` until lines turn **black** (fully defined).
6. **Exit & Validate Sketch:** Exit Sketch; ensure no dangling/zero-length/self-intersecting contours.
7. **Apply Substantial Solid Feature:** Run `Extruded Boss/Base` (`Blind` or `Mid Plane`) or `Revolved Boss/Base` (`360°`)—never build the main body out of surfaces or stacked primitive blocks. Confirm `Merge result` is checked on subsequent additive bosses.
8. **Confirm, Rebuild & Inspect:** Accept (`OK`), run `Ctrl+Q` / `Rebuild`, and inspect rotated views against the reference before adding dependent features.
9. **Refine on Planar Faces (`Normal To`):** Select planar solid faces or reference planes (`Normal To`), constrain new sketches to existing edges/vertices, group identical paired same-face cutouts (`=` relations per `Sİ 2`) when logical, and apply `Extruded Cut` (`Blind`, `Through All`, `Flip side to cut`) or secondary `Extruded Boss/Base` (`Through All`, `Merge result`). Keep vertical columns/walls straight unless the drawing proves a taper.
10. **Mirror Complete Symmetric Structures & Finish Edges:** When using 3D `Mirror`, select the **entire symmetric side-assembly feature group** (not just a central feature) across the true symmetry plane, excluding genuinely asymmetric features. Add justified `Fillet`/`Chamfer` features last, keeping default SOLIDWORKS names (`Sketch1`, `Boss-Extrude1`, `Cut-Extrude1`, `Mirror1`, etc.) for single parts.
11. **Final Verification:** Follow `./verification-and-recovery.md` (rebuild, single body count, bounding box, mass/volume, **physical left/right structural symmetry**, **straight vertical wall check**, and multi-view visual comparison). Capture temporary view screenshots only when needed and keep them outside `outputs/Part_XX/vNNN/`.
12. **Save Versioned Outputs:** Following `AGENTS.md` Section 7, inspect existing `outputs/Part_XX/` versions without overwriting prior work, save `Part_XX_vNNN.SLDPRT` and export `Part_XX_vNNN.STEP` into `outputs/Part_XX/vNNN/`, and update lightweight `outputs/Part_XX/README.md`.

---

## 2. Direct Local COM/API Automation (When Scripting Live SOLIDWORKS)

If desktop GUI clicks are unavailable or slower than COM scripting, and Windows has SOLIDWORKS 2026 installed (`SldWorks.Application` ProgID registered):
- Complete the 16-item pre-modeling plan first and follow the exact same solid-first, balanced-granularity, Smart-Dimensioned, native-feature rules as `./vba-api-fallback.md`.
- **Preferred Execution Engine on Windows (Zero Python `win32com` Dependency):** Compile a lightweight x64 C# builder using `.NET Framework 4.x csc.exe` (`C:\Windows\Microsoft.NET\Framework64\v4.0*\csc.exe`) referencing `SolidWorks.Interop.sldworks.dll` and `SolidWorks.Interop.swconst.dll` from `C:\Program Files\SOLIDWORKS Corp\SOLIDWORKS\api\redist\`.
- **Verified SOLIDWORKS 2026 API Rules (Language-Independent):**
  1. **Standard Planes & Origin:** Locate `Front`, `Top`, `Right` by iterating `FirstFeature()` for `GetTypeName2() == "RefPlane"` (`1=Front`, `2=Top`, `3=Right`) rather than localized plane names; select Origin via `Extension.SelectByID2("", "EXTSKETCHPOINT", 0, 0, 0, ...)`.
  2. **Planar-Face Sketch Coordinates:** Always convert 3D model `(X, Y, Z)` coordinates to local sketch `(u, v)` via `ISketch.ModelToSketchTransform` so face-orientation flips never break sketch geometry.
  3. **Verified Constraint Strings (`SketchAddConstraints`):**
     - Collinear is spelled **`"sgCOLINEAR"`** (single `L` — `"sgCOLLINEAR"` silently fails).
     - Point-to-point horizontal/vertical alignment uses **`"sgHORIZONTALPOINTS2D"`** / **`"sgVERTICALPOINTS2D"`**.
     - Always verify `(swConstrainedStatus_e)sk.GetConstrainedStatus()` after adding relations & `AddDimension2` + `SetSystemValue3`.
  4. **Extrude / Cut Selection & Direction:** Right after `skMgr.InsertSketch(true)`, select the just-closed sketch via `((IFeature)model.FeatureByPositionReverse(0)).Select2(false, 0)` before calling `FeatureExtrusion3` or `FeatureCut4`:
     - In `FeatureExtrusion3(Sd, Flip, Dir, ...)`, **`Dir`** reverses extrude direction (`true` = opposite face normal).
     - In `FeatureCut4(Sd, Flip, Dir, ...)`, **`Flip`** is **`Flip side to cut`** (cuts outside the closed contour per `Sİ 4, 5`).
  5. **Chamfers & Tangent Reference Planes (`Sİ 5`):**
     - Use `featMgr.InsertFeatureChamfer((int)swFeatureChamferOption_e.swFeatureChamferTangentPropagation, (int)swChamferType_e.swChamferAngleDistance, dist, angleRad, ...)` on pre-selected edges (`CreateDefinition(swFmChamfer)` may return `null`).
     - For tangent planes (`Sİ 5`), select `Top Plane` **First** (`swRefPlaneReferenceConstraint_Parallel`) and the cylindrical face **Second** (`swRefPlaneReferenceConstraint_Tangent`), then verify `IRefPlane.Transform` sign (with `Distance` offset fallback if needed).
  6. **Instructor-Matching Appearance & Display (Tier 3):** When no custom material/color is specified, apply **`Plain Carbon Steel`** (`C:\Program Files\SOLIDWORKS Corp\SOLIDWORKS\lang\english\sldmaterials\solidworks materials.sldmat`) via `part.SetMaterialPropertyName2` and set `model.ActiveView.DisplayMode = (int)swViewDisplayMode_e.swViewDisplayMode_ShadedWithEdges` before capturing multi-view verification renders and saving.
- Keep `Merge = True` for single-body parts, run `ForceRebuild3(False)`, verify solid body count (`GetBodies2`), bounding box (`GetPartBox`), `CoM` physical symmetry, and analytical volume.
- Save both `Part_XX_vNNN.SLDPRT` and `Part_XX_vNNN.STEP` into `outputs/Part_XX/vNNN/` (never overwriting completed versions), verify SLDPRT reopen + `ForceRebuild3`, and update `outputs/Part_XX/README.md`.
- If COM instantiation fails (SOLIDWORKS not installed, modal dialog, COM registration error), stop guessing and fall back cleanly to Priority 2 (complete VBA macro).
