# Verification & Error Recovery Reference

A valid SOLIDWORKS rebuild does NOT guarantee the model matches the drawing or photograph. Perform both **geometric verification** and **visual verification**—and never claim runtime verification unless SOLIDWORKS actually executed and returned the observed results.

---

## 1. Geometric & CAD Integrity Checklist

Verify whenever live execution permits (explicitly mark anything not executed as `Not verified`):
- **Rebuild status:** Zero errors/warnings in FeatureManager tree (`ForceRebuild3` = True).
- **Sketch validity:** Closed contours where required, no zero-length or self-intersecting edges, critical geometry fully constrained via relations + Smart Dimensions (black sketch status).
- **Solid body count & merge check:** `1` solid body for a single machined/molded/cast component (`GetBodies2(swSolidBody, True)`), confirming `Merge result` succeeded. Unexpected multi-body results indicate a disjoint boss or incomplete cut (only justified for intentional multi-body FEA parts like `Sİ 9`).
- **Overall dimensions / bounding box:** Verify `L × W × H` (`GetPartBox`) matches the dimension map.
- **Volume & mass:** Sanity-check `GetMassProperties2` / `CreateMassProperty2` (avoid obsolete `GetMassProperties`), and cross-check SOLIDWORKS `Volume` against analytical geometry calculation when dimensions are fully confirmed.
- **Appearance & display (Tier 3):** Confirm `Shaded With Edges` (`swViewDisplayMode_ShadedWithEdges`) and `Plain Carbon Steel` (when no custom material is specified) so edges and faces match the instructor's visual contrast.
- **Feature tree quality:** Balanced granularity (neither overly fragmented into micro-features nor crammed into one mega-sketch), solid-first native features (no surface-based main-body approximations or primitive stacking), and default SOLIDWORKS single-part naming (`Sketch1`, `Boss-Extrude1`, `Cut-Extrude1`, `Mirror1`, etc.).
- **Complete Physical Symmetry Check:**
  - **The presence of a `Mirror` feature in the FeatureManager tree is NOT proof of correct symmetry.**
  - Inspect `Mirror` seed features and symmetry plane, then **physically compare both sides of the resulting 3D solid**: matching left/right buttresses, sloped supports, raised sections, vertical columns, base extensions, bevels, thicknesses, positions, and openings/cuts, plus symmetric `CoM` alignment and symmetric bounding box bounds relative to the symmetry plane (while confirming genuinely asymmetric features were excluded).
- **Straight Vertical Geometry Check:**
  - Inspect vertical columns, straight walls, and raised supports in **Front**, **Left/Right**, and **Top** views.
  - Confirm they remain vertically straight with **zero** perspective-induced inward slopes, arbitrary bevels, or unjustified angled cuts.

---

## 2. Visual Verification (When Needed)

Rendered screenshots are **optional** verification aids—create temporary view renders only when genuinely needed for debugging or visual comparison, and never store them inside `outputs/Part_XX/vNNN/`. When inspecting live SOLIDWORKS views or temporary renders:
1. Inspect **Front**, **Back**, **Top**, **Left**, **Right**, and **Isometric** views (plus the photo-matching angle if helpful).
2. Check systematically:
   - Overall silhouette & aspect ratios
   - Straightness of vertical columns/walls vs. intentional tapers/bevels
   - Stepped diameters / heights / flange thicknesses
   - Exact count, size, and placement of holes, slots, ribs, buttresses, and bosses
   - Edge transitions (fillets vs. chamfers vs. sharp shoulders)
   - Complete left/right structural symmetry and depth relationships
3. **If any major visual or structural mismatch exists:** Do NOT stop. Identify which sketch dimension or feature parameter caused the discrepancy, edit the native sketch/feature (never stack patch solids or surface caps on top), rebuild, and re-inspect.

---

## 3. Completion Gate (Per `AGENTS.md` Section 7)

Report **`COMPLETED`** ONLY when all four conditions are verified:
1. `outputs/Part_XX/vNNN/Part_XX_vNNN.SLDPRT` exists and saved cleanly.
2. `outputs/Part_XX/vNNN/Part_XX_vNNN.STEP` exists and STEP export succeeded.
3. Both files match the sequential version folder `vNNN` (without overwriting prior versions).
4. Saved model rebuilt (`ForceRebuild3`) with zero errors.

If STEP export fails (even when `.SLDPRT` saved), report **`PARTIAL`** or **`FAILED`**, never `COMPLETED`.

---

## 4. Error Recovery Protocol

### A. Desktop / Live COM Operation Failures
1. **Identify root cause:** Inspect the active plane, sketch open/closed contour, self-intersections, selection marks, feature end condition, `Merge result` state, or zero-thickness error.
2. **Fix the real CAD cause:**
   - Zero-thickness geometry → adjust coincident boundary or slight overlap/offset, or reorder feature.
   - Fillet failed → check radius < adjacent edge/wall limit, split fillet into separate features, or apply before/after conflicting cut.
   - Sketch failed to extrude/revolve → verify closed loop, remove duplicate overlapping segments, ensure revolve profile does not cross the centerline.
   - Mirror omitted side-assembly features → edit `Mirror` feature seed list to include the complete symmetric feature group.
3. **Retry** the clean feature workflow. Never revert to stacking primitives or surface patches to work around a sketch/feature bug.

### B. VBA Macro Failures
1. **Diagnose exact failing line/step:** Check `SelectByID2` entity name/coordinates (e.g., `"Front Plane"` vs localized plane names or coordinates off-entity), sketch state (`InsertSketch`), parameter count/types, SI unit scaling (meters vs mm), or missing template.
2. **Fix the complete macro:** Always return the **entire corrected VBA module** ready to paste and run—never ask the user to manually splice partial code fragments.
3. **Manual fallback (Priority 3):** If SOLIDWORKS environment/COM issues block macro execution entirely, provide the shortest clean manual modeling guide.

---

## 5. Honest Reporting Labels

Always classify verification claims using exact factual labels:
- `Tested successfully` — actually executed and confirmed in SOLIDWORKS / tool output.
- `Source-verified` — directly observed in user data, drawings, instructor source, or saved model properties.
- `Calculated` / `Estimated` / `Assumed` — clearly labeled per dimension/property.
- `Not verified` — code/instructions generated without live SOLIDWORKS execution or visual inspection.
