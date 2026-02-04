# PR3 — Galerkin grid and mapping utilities

## Completed work from prior PRs
- PR1: Fortran RDCON test harness, reference fixtures, and Julia comparison utilities.
- PR2: Hermite basis utilities and toolbox helpers.

## Goal
Port grid construction, element tagging, and local-to-global DOF mapping for the Galerkin solver.

---

## Scope and deliverables

### 1) Grid node generation
- Create radial grid nodes for the outer-region FEM problem.
- Ensure spacing matches Fortran (including packed nodes near singular surfaces).

### 2) Element tagging and bookkeeping
- Mark elements as N/R/E based on resonance locations.
- Store element boundaries and node indices.

### 3) Global DOF mapping
- Map local element DOFs to global indices with the same ordering as Fortran.

---

## Fortran subroutines to convert
- `gal_make_grid`
- `gal_diagnose_grid`
- `gal_make_map`
- `gal_diagnose_map`

---

## Detailed task list

### A) Source audit
- Identify node placement rules in `gal_make_grid`.
- Extract element ordering and DOF layout assumptions.

### B) Julia implementation
- Add a `GalGrid` structure (nodes, elements, tags).
- Add a `GalMap` structure for DOF indices.
- Include diagnostic functions mirroring Fortran outputs.

### C) Tests
- Compare node positions, element types, and DOF mappings to Fortran fixtures.

---

## Acceptance criteria
- Julia grid and mapping outputs match Fortran for the reference cases.
- Diagnostics align with Fortran’s reported counts and ranges.

---

## Out of scope
- Quadrature and basis evaluation.
- Matrix/RHS assembly.
