# SOLIDWORKS 2026 VBA / API Automation Fallback (Priority 2)

Use this path when direct desktop/COM SOLIDWORKS modeling is unavailable or fails.

**Pre-Generation Gate:** Complete and present the **mandatory 16-item pre-modeling plan** (`AGENTS.md` Section 4) *before* generating any VBA macro code.

---

## 1. Mandatory VBA Macro Standards

Every generated macro MUST be a complete, standalone, ready-to-run SOLIDWORKS 2026 VBA module:
- Start with `Option Explicit` and include `Sub main()`.
- **Zero placeholders, zero omitted sections, zero pseudo-code.**
- **SI units strictly:** SOLIDWORKS API expects **meters** (`mm * 0.001`) and **radians** (`deg * PI / 180#`). Always provide `MM(val)` and `DegToRad(val)` helper functions.
- **Template safety (no obsolete `NewPart`):** Resolve a valid `.prtdot` path via `swDefaultTemplatePart`, `swFileLocationsDocumentTemplates`, `%ALLUSERSPROFILE%\SOLIDWORKS\SOLIDWORKS 2026\templates\Part.prtdot`, or `GetExecutablePath() & "\lang\english\Tutorial\part.prtdot"`, and open it with `swApp.NewDocument(tmpl, 0, 0, 0)`. Raise an explicit error if no template exists.
- **Balanced, solid-first sketch & feature workflow:**
  1. Select plane or planar face with `SelectByID2` (always verify `boolstatus = True`).
  2. `swModel.SketchManager.InsertSketch True`.
  3. Draw clean geometry (`CreateLine`, `CreateCenterRectangle`, `CreateCircleByRadius`, `CreateArc`, `CreateSlot`, `CreatePolygon`, etc.), anchor to Origin/model edges, and mark axes as construction (`seg.ConstructionGeometry = True`). Avoid both excessive fragmentation into tiny features and cramming an entire 3D part into one giant sketch.
  4. Apply sketch relations (`swModel.SketchAddConstraints "sgHORIZONTAL2D"`, `"sgVERTICAL2D"`, `"sgSYMMETRIC"`, `"sgCONCENTRIC"`, `"sgTANGENT"`, `"sgEQUAL"`, `"sgCOINCIDENT"`). Use `"sgVERTICAL2D"` / `"sgHORIZONTAL2D"` rigorously so straight columns and vertical walls never tilt.
  5. Apply Smart Dimensions (`swModel.AddDimension2`) with `SetSystemValue3` (check return `= swSetValueReturnStatus_e.swSetValue_Successful`) while suppressing interactive input popups (`swApp.SetUserPreferenceToggle swUserPreferenceToggle_e.swInputDimValOnCreate, False`—always restored in `Cleanup`).
  6. Exit sketch (`InsertSketch True`), clear selections, then execute native solid features:
     - Substantial solid Boss/Base extrude: `IFeatureManager::FeatureExtrusion3` (`Merge = True` for single-body parts)
     - Refinement cut extrude: `IFeatureManager::FeatureCut4` (supports `swEndCondBlind`, `swEndCondThroughAll`, and `Flip` / `FlipSideToCut` when cutting outside a profile per `Sİ 4, 5`)
     - Boss/Cut revolve: `IFeatureManager::FeatureRevolve2` (`Merge = True`)
     - Fillets, chamfers, patterns, and mirrors: prefer modern definition-based creation (`IFeatureManager::CreateDefinition` + `CreateFeature` with `swFmFillet` / `ISimpleFilletFeatureData2`, `swFmChamfer` / `IChamferFeatureData2`, `swFmCirPattern` / `ICircularPatternFeatureData`, `swFmMirror` / `IMirrorPatternFeatureData`) rather than obsolete methods (`FeatureFillet3`, `InsertFeatureChamfer`, `FeatureCircularPattern4`/`5`, `FeatureMirror2`).
     - **Complete symmetry in `IMirrorPatternFeatureData`:** When using 3D `Mirror`, pre-select **all** features belonging to the symmetric side-assembly (buttresses, sloped supports, raised sections, columns, extensions, bevels, and related cuts)—never mirror only a central cradle/feature while omitting side structures. Exclude genuinely asymmetric features.
  7. Validate `Not swFeat Is Nothing`; **keep default SOLIDWORKS feature and sketch names** (`Sketch1`, `Boss-Extrude1`, `Cut-Extrude1`, `Mirror1`, etc.) for single-part modeling—do NOT overwrite `swFeat.Name` with custom names.
  8. `swModel.ForceRebuild3 False`.
  9. Verify solid body count (`GetBodies2` = 1 unless justified), bounding box (`GetPartBox`), and mass properties (`GetMassProperties2` or `CreateMassProperty2`—avoid obsolete `GetMassProperties`).
  10. Save BOTH `Part_XX_vNNN.SLDPRT` and `Part_XX_vNNN.STEP` into `outputs/Part_XX/vNNN/` (`swModel.Extension.SaveAs3`) with explicit error/warning checks on both saves (never overwriting previous completed versions per `AGENTS.md` Section 7).
- **Forbidden shortcuts:** Never build the main structural body out of surfaces (`InsertSurface...` / surface patches) or stack separate dumb cylinders/blocks + boolean `Combine` when a sketch-driven `FeatureExtrusion3` / `FeatureRevolve2` + `FeatureCut4` represents the real part.
- **Explicit error handling:** Use `On Error GoTo ErrHandler`, restore toggled user preferences (`swInputDimValOnCreate`) in `Cleanup`, and report exact step/feature failure context.

---

## 2. Key SOLIDWORKS 2026 API Signatures

### `IFeatureManager::FeatureExtrusion3` (23 parameters)
```vb
Set swFeat = swFeatMgr.FeatureExtrusion3( _
    Sd, Flip, Dir, _
    T1, T2, D1, D2, _
    Dchk1, Dchk2, Ddir1, Ddir2, Dang1, Dang2, _
    OffsetReverse1, OffsetReverse2, TranslateSurface1, TranslateSurface2, _
    Merge, UseFeatScope, UseAutoSelect, _
    T0, StartOffset, FlipStartOffset)
```
Common constants: `T1 = swEndConditions_e.swEndCondBlind` (or `swEndCondMidPlane`, `swEndCondThroughAll`), `T0 = swStartConditions_e.swStartSketchPlane`, `Merge = True`.

### `IFeatureManager::FeatureCut4` (27 parameters)
```vb
Set swFeat = swFeatMgr.FeatureCut4( _
    Sd, Flip, Dir, _
    T1, T2, D1, D2, _
    Dchk1, Dchk2, Ddir1, Ddir2, Dang1, Dang2, _
    OffsetReverse1, OffsetReverse2, TranslateSurface1, TranslateSurface2, _
    NormalCut, UseFeatScope, UseAutoSelect, _
    AssemblyFeatureScope, AutoSelectComponents, PropagateFeatureToParts, _
    T0, StartOffset, FlipStartOffset, OptimizeGeometry)
```
Common cut constants: `T1 = swEndConditions_e.swEndCondThroughAll` (or `swEndCondBlind` with `D1` in meters); `Flip = True` flips side to cut (outside closed contour, as in `Sİ 4, 5`).

### `IFeatureManager::FeatureRevolve2` (20 parameters)
```vb
Set swFeat = swFeatMgr.FeatureRevolve2( _
    SingleDir, IsSolid, IsThin, IsCut, ReverseDir, BothDirectionUpToSameEntity, _
    Dir1Type, Dir2Type, Dir1Angle, Dir2Angle, _
    OffsetReverse1, OffsetReverse2, ThinType, ThinThickness1, ThinThickness2, _
    OffsetDistance1, OffsetDistance2, Merge, UseFeatScope, UseAutoSelect)
```
For a full 360-degree solid boss revolve: `SingleDir:=True, IsSolid:=True, IsThin:=False, IsCut:=False, Dir1Type:=swEndCondBlind, Dir1Angle:=2 * PI, Merge:=True`. Ensure the centerline axis is drawn in the sketch (or selected with the required mark when multiple construction lines exist).

### Definition-Based Features (`CreateDefinition` + `CreateFeature`)
```vb
' Example pattern for Fillets / Chamfers / Patterns / Mirrors:
Dim swData As SldWorks.SimpleFilletFeatureData2
Set swData = swFeatMgr.CreateDefinition(swFeatureNameId_e.swFmFillet)
swData.Initialize swSimpleFilletType_e.swConstRadiusFillet
swData.DefaultRadius = MM(3)
' Pre-select target edges via SelectByID2, then:
Set swFeat = swFeatMgr.CreateFeature(swData)
```

---

### `SketchAddConstraints` & Feature Selection Pitfalls (SOLIDWORKS 2026 Verified)
- **`"sgCOLINEAR"`** uses **one `L`** (not `"sgCOLLINEAR"`).
- Point-to-point alignment uses **`"sgHORIZONTALPOINTS2D"`** / **`"sgVERTICALPOINTS2D"`**.
- Always select the sketch before `FeatureExtrusion3`/`FeatureCut4` (e.g., `swModel.FeatureByPositionReverse(0).Select2 False, 0`).
- Use `InsertFeatureChamfer` on pre-selected edges when `CreateDefinition(swFmChamfer)` returns `Nothing`.
- For visual parity with instructor models (Tier 3): apply `"Plain Carbon Steel"` via `swPart.SetMaterialPropertyName2` (when available) and set `swModel.ActiveView.DisplayMode = swViewDisplayMode_e.swViewDisplayMode_ShadedWithEdges`.

---

## 3. Useful Sketch Constraint Names (`SketchAddConstraints`)
- `"sgHORIZONTAL2D"`, `"sgVERTICAL2D"`, `"sgHORIZONTALPOINTS2D"`, `"sgVERTICALPOINTS2D"`
- `"sgCOINCIDENT"`, `"sgCONCENTRIC"`, `"sgTANGENT"`, `"sgCOLINEAR"`
- `"sgPARALLEL"`, `"sgPERPENDICULAR"`, `"sgEQUAL"`
- `"sgSYMMETRIC"` (select 2 entities + 1 centerline), `"sgMIDPOINT"`

---

## 4. Reference Template
Start every generated VBA macro from `./vba-template.bas`, replacing the modeling section with the part's complete, verified sketch-and-feature sequence.
