# Photo, Drawing & Dimension Analysis Reference

Inspect every uploaded photograph or technical drawing carefully before planning features, opening SOLIDWORKS, or writing macro code. *(Note: Optical photo interpretation, vertical-column distortion protection, and dimension classification tags are supplemental Tier 3 engineering guidelines—the instructor document `CAD-CAE-CAM-Serbest-Ish-2026.docx` uses dimensioned drawings and physical lab measurements rather than unscaled perspective photos.)*

---

## 1. View Priority & Geometry Interpretation

### Drawing vs. Photo Priority
- **Prioritize explicit dimension annotations** over visual estimation.
- **Prioritize orthographic views** (`Front`, `Top`, `Side`, section views) over isometric or perspective images for true angles, wall verticality, and proportions.
- Use **isometric views** to understand 3D spatial relationships and feature connectivity, **never** to override explicit dimensions or orthographic straightness.
- **Never silently alter source geometry** to make modeling easier. Mark genuinely ambiguous geometry as `UNCERTAIN` rather than inventing certainty.

### Geometry Checklist
Identify and catalog:
- **Overall envelope & symmetry:** Part-level symmetry, central features, and complete left/right structural assemblies.
- **Main body form:** Stepped prismatic block, bracket, turned/cylindrical shaft, flat plate contour, housing, or multi-branch body.
- **Cylindrical, conical, and stepped sections:** Coaxial diameters, shoulders, chamfers, tapers, undercuts.
- **Subtractive features:** Through-holes vs. blind holes, pockets, slots, keyways, corner/step cutouts, grooves.
- **Protrusions & reinforcements:** Buttresses, sloped supports, raised sections, vertical columns, base extensions, bosses, lugs, ribs, flanges.
- **Edge & thread details:** Cosmetic threads (`Cosmetic Thread` per `Sİ 4`), fillets, chamfers, bevels.
- **Likely manufacturing logic (only where supported by the drawing):** Turned + milled flats/keyways (`Sİ 4, 5`), prismatic milled/cut pockets (`Sİ 2, 3`), flat cut plate (`Sİ 1`), cast/machined bracket.

### Perspective & Optical Correction
Never trace a perspective photograph as if it were an orthographic drawing:
- **Perspective convergence:** Parallel edges appear to converge toward vanishing points; infer true parallel/perpendicular faces unless the drawing proves a real taper.
- **Foreshortening:** Faces angled away from the camera look shorter than their true length; cross-check across multiple views.
- **Ellipses vs. circles:** Circular features viewed obliquely appear elliptical; major axis indicates true diameter orientation.
- **Shadows & highlights:** Do not mistake cast shadows or specular edge reflections for steps, grooves, or bevels.
- **Occluded geometry:** Infer hidden back faces and through-cut continuity from engineering function, orthographic projections, and verified symmetry.

---

## 2. Straight Vertical Geometry Protection

When a drawing or reference image shows a **vertical column, straight wall, or raised support**:
- **Preserve vertical orientation:** Constrain vertical profile edges with `Vertical` relations and keep extruded walls perpendicular to the base/datum plane.
- **Forbid perspective-induced slopes:** Do NOT reinterpret vertical columns or straight walls as inward-sloping faces because of camera perspective convergence in an isometric photo.
- **Justify every angle/cut:** Do NOT introduce inward slopes, arbitrary bevels, chamfers, or angled cuts that change a straight vertical profile unless the drawing or reliable orthographic evidence explicitly shows them.
- **Orthographic check:** Whenever a surface should be vertical, verify its straightness in **Front**, **Side**, and relevant orthographic views before adding any angled transition or side cut.

---

## 3. Multi-Level Symmetry Breakdown & Grouping

Evaluate symmetry at **all seven structural levels** before planning the FeatureManager tree:
1. **Part-level symmetry** (overall envelope and primary datum planes)
2. **Central feature symmetry** (cradle, central bore, central web/boss)
3. **Left/right structural symmetry** (complete side structures)
4. **Buttress & sloped-support symmetry**
5. **Raised section & vertical column symmetry**
6. **Base extension & flange/bevel symmetry**
7. **Profile, opening, and cut symmetry**

### Required Pre-Modeling Symmetry Table
Explicitly list and classify (`CONFIRMED`, `INFERRED`, or `UNCERTAIN`):
- **Symmetry plane(s):** e.g., `Right Plane` or `Front Plane` (`Mid Plane`).
- **Central geometry:** Features straddling the symmetry plane.
- **Complete symmetric structural group(s):** Every feature belonging to the symmetric side assembly (main structural buttress, sloped support, upper raised section, vertical column, lower structural extension, base bevel, associated profile geometry, related openings and cuts). *Mirroring only a central cradle or isolated sub-feature is never sufficient when the full side structure is symmetric.*
- **Genuinely asymmetric features:** Any lug, notch, hole, or boss that exists on one side only and must NOT be mirrored.
- **Realization method:** Sketch-level symmetry (`Mirror Entities`, `=` Equal constraints on paired cutouts per `Sİ 2`, `Mid Plane` extrude per `Sİ 7`) vs. 3D native `Mirror` of the complete side-assembly feature group (supplemental Tier 3 rule).

---

## 4. Dimension Extraction & Classification

### Dimension Classification Tags
Classify every key dimension in your dimension map and final report:
- `CONFIRMED`: Explicitly given by the user, read from drawing annotations, or measured against an unambiguous scale reference.
- `CALCULATED`: Derived mathematically from confirmed dimensions (e.g., total length from stepped segments, center distance from symmetry).
- `ESTIMATED`: Inferred visually from multi-view proportions, foreshortening correction, or standard mechanical sizes.
- `ASSUMED`: Chosen by engineering judgment when occluded or unmeasurable (e.g., minor fillet radius, unscaled overall envelope).
- `UNKNOWN`: Missing and cannot be reliably inferred; flag explicitly if critical.

### Priority Order & Autonomy
1. Explicit dimension annotations / user-provided values (`CONFIRMED`)
2. Orthographic drawing views & reference scales (`CONFIRMED`)
3. Mathematically derived values (`CALCULATED`)
4. Multi-view proportional estimates (`ESTIMATED`)
5. Standard engineering sizes (`ESTIMATED`, e.g., standard clearance holes and metric plate thicknesses)
6. Minimal closing assumptions (`ASSUMED`)

If a dimension is unavailable, document the missing value clearly, verify whether an engineering estimate allows faithful reconstruction without risking a fundamentally different part, and disclose explicitly when no absolute scale reference exists. Tabulate the dimension map and verify consistency (sum of steps = total length; hole diameter < boss diameter; valid wall margins) before modeling.
