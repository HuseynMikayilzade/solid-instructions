# Sketch-First, Solid-First & Feature-Based Modeling Standards

Construct every part as an experienced mechanical CAD engineer would in SOLIDWORKS 2026—clean, parametric, editable, and faithful to the instructor's documented methodology (`CAD-CAE-CAM-Serbest-Ish-2026.docx`).

---

## 1. Instructor Methodology vs. Supplemental SOLIDWORKS Practices

Follow the strict 3-tier hierarchy from `AGENTS.md` Section 1—never present Tier 3 supplemental techniques as instructor requirements:

### Tier 1 (`DOCUMENTED`) & Tier 2 (`OBSERVED PATTERN`) — Instructor Workflows
- **Uniform-thickness flat contours (`Sİ 1, 6`):** Build the full 2D contour on `Top` using construction `Centerline`s (`Midpoint` to Origin), bi-directional `Offset Entities`, `Trim Entities`, `Sketch Fillet`, `Mirror Entities` (horizontal/vertical), or `Circular Sketch Pattern`, fully define until **black**, and extrude in one `Boss-Extrude` (`Blind`, 20 mm).
- **Stepped / complex 3D prismatic parts (`Sİ 2, 3`):**
  1. Start `Sketch1` on a standard plane (`Front`), anchored to the **Origin**, constrained with `Horizontal`/`Vertical` relations and `Smart Dimension` until **black** (fully defined).
  2. Apply `Extruded Boss/Base` (`Blind` or `Mid Plane`) to build a **substantial primary solid body** first (`Sİ 3` explicitly specifies *"Çəkiliş metodu Sİ 2 ilə eynidir"* — same method as `Sİ 2`).
  3. Sketch subsequent refinements directly on planar solid faces (`Normal To`), constraining edges `Coincident` to existing solid edges/vertices.
  4. Group identical paired cutouts on the same face in **one sketch** using `=` (`Equal`) relations (`Sketch3` in `Sİ 2`) and cut together with one `Cut-Extrude` (`Through All`).
  5. Add protruding lugs/bosses on planar faces (`Boss-Extrude`, `Through All`, `Merge result` checked) and bore holes via `Cut-Extrude` (`Through All`).
- **Turned / cylindrical + prismatic parts (`Sİ 4, 5`):**
  - `Sİ 4`: Sketch half longitudinal section + `Centerline` on `Front` → `Revolved Boss` (`360°`) for the bulk solid → `Polygon` sketch + `Cut-Extrude` (`Flip side to cut`) for hex/prismatic flats → `Cosmetic Thread`.
  - `Sİ 5`: Extrude cylindrical stock → shape steps/squares via `Cut-Extrude` (`Flip side to cut`) → `Chamfer` → tangent `Plane1`/`Plane2` (parallel to `Top`, tangent to cylinder) for keyways (`Straight Slot` / rectangle + `Cut-Extrude`).
- **Single-part FeatureManager naming (`Sİ 2, 4, 5, 9`):** Keep default SOLIDWORKS names (`Sketch1`, `Boss-Extrude1`, `Cut-Extrude1`, `Chamfer1`, `Plane1`). *(Descriptive sketch renaming appears only in `Sİ 7` multi-part cam assembly.)*
- **Solid-only construction (`Sİ 1–10`):** Zero surface-modeling features are used anywhere in the instructor's examples.

### Tier 3 (`NOT SPECIFIED` in Source) — Supplemental SOLIDWORKS Engineering Practices
Use only where the instructor's material does not contradict them:
- **3D feature-level `Mirror`** (mirroring a complete symmetric side-support feature group across a center plane) and feature `Linear`/`Circular Pattern`.
- `Hole Wizard`, `Shell`, `Rib`, `Loft`, and `Sweep` when geometry genuinely calls for them.

---

## 2. Balanced Feature Granularity & Solid-First Strategy

Before creating any sketch or feature, choose the optimal, balanced feature breakdown:
- **Avoid Incorrect Approach A — Excessive Fragmentation:** Do NOT unnecessarily split one logical structural body, stepped silhouette, or paired same-face cutouts (`=` relations per `Sİ 2`) into many tiny sketches and micro-features.
- **Avoid Incorrect Approach B — One Giant Mega-Sketch:** Do NOT cram an entire multi-plane 3D part with unrelated bosses, cuts, and side supports into one overcrowded sketch.
- **Solid-First Construction Rules:**
  - Create **substantial, complete structural solid sections** (`Boss-Extrude` / `Revolve`) and refine them with native `Cut-Extrude` (`Blind`, `Through All`, `Flip side to cut`) where logical and consistent with `Sİ 2–5`. (Never force solid-first blindly if an instructor example demonstrates a better-fitting method.)
  - Ensure `Merge result` is checked so connected features merge into **one solid body** (unchecking `Merge result` is reserved for intentional multi-body FEA models like `Sİ 9`).
  - **Forbidden:** Building the primary body out of surfaces or thin surface-like patches, stacking unrelated primitive blocks/cylinders + `Combine`, or leaving "dumb" non-parametric geometry.

---

## 3. Coordinate System, Sketch Relations & Smart Dimensions

- **Origin & Planes:** Anchor `Sketch1` to the Origin (`Исходная точка`). For symmetric parts, center the Origin on the true symmetry plane (`Front` / `Right` `Mid Plane` or centerline); for turned parts, place the Origin on the revolution axis at a datum end face. Use standard planes (`Front`, `Top`, `Right`) and planar solid faces (`Normal To`) whenever possible; add `Reference Geometry → Plane` only when needed (e.g., tangent planes in `Sİ 5`, center symmetry plane).
- **Preferred Sketch Entities:** `Line`, `Centerline` (`For construction`), `Circle`, `Centerpoint/3-Point Arc`, `Corner/Center Rectangle`, `Straight/Arc Slot`, `Polygon`. Reserve `Spline` for genuinely freeform profiles (or `Fit Spline` on cams per `Sİ 7`).
- **Required Relations:** `Horizontal`, `Vertical` (critical for protecting straight walls/columns!), `Coincident`, `Concentric`, `Tangent`, `Equal` (`=`), `Parallel`, `Perpendicular`, `Symmetric`, `Midpoint`. Never abuse `Fix` instead of dimensions/relations.
- **Smart Dimension Discipline:** Dimension overall envelope (`L × W × H`), diameters (across centerline for revolved profiles), step lengths, wall/flange thicknesses, hole centers/edges, and angles until geometry turns **black** (fully defined) without over-defining. Prefer feature `Fillet`/`Chamfer` near the end of the tree (except planar 2D contour corner fillets as in `Sİ 1`).

---

## 4. Symmetry Implementation & Vertical Wall Discipline

- **Sketch-level symmetry (`DOCUMENTED`):** Use `Centerline` + `Mirror Entities` (`Sİ 1, 6`), paired shapes with `Equal` (`=`) relations in one face sketch (`Sİ 2` `Sketch3`), or `Mid Plane` extrusions (`Sİ 7`).
- **3D feature-group symmetry (`NOT SPECIFIED` / Tier 3):** When a multi-feature 3D side structure is symmetric (buttress, sloped support, upper raised section, vertical column, lower extension, base bevel, associated cuts), model one complete side assembly progressively and mirror the **entire symmetric feature group** across the true center plane—never mirror only a central cradle while omitting or guessing opposite side supports. Exclude genuinely asymmetric features from the mirror selection.
- **Straight Vertical Geometry Protection:** Constrain vertical columns and straight walls with `Vertical` relations and perpendicular face extrusions. Never add inward slopes, arbitrary bevels, or unjustified cuts unless explicitly shown in orthographic views.

---

## 5. Mandatory 16-Item Planning Template & Typical Tree Order

Complete all 16 items **before** starting CAD execution:
1. Geometry interpretation | 2. Coordinate system | 3. Confirmed dimensions | 4. Calculated dimensions | 5. Missing dimensions | 6. Estimates | 7. Symmetry analysis | 8. Complete symmetric structural groups (+ asymmetric exclusions) | 9. Feature breakdown & rationale (major shapes, why separate vs. combined, cuts, mirror/pattern, efficiency/faithfulness) | 10. Feature sequence | 11. Sketch placement | 12. Additive features | 13. Cutting features | 14. Mirror/Pattern ops | 15. Expected solid body count | 16. Verification plan.

### Typical Balanced FeatureManager Sequence (Default Names)
1. `Sketch1` → `Boss-Extrude1` or `Revolve1` (substantial primary solid body)
2. `Sketch2` → `Cut-Extrude1` (major step/recess/slot refinement)
3. Additional planar-face sketches → `Boss-Extrude` / `Cut-Extrude` (supports, lugs, paired `=` cutouts, holes)
4. `Mirror1` / `LPattern1` / `CirPattern1` (complete symmetric side-assembly feature group or pattern, when 3D feature symmetry applies)
5. `Fillet1` / `Chamfer1` (edge finishing justified by the drawing)
