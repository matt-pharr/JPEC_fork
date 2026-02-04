# PR5 — Galerkin data allocation + arrays

## Completed work from prior PRs
- PR1: Fortran RDCON test harness, reference fixtures, and Julia comparison utilities.
- PR2: Hermite basis utilities and toolbox helpers.
- PR3: Grid and DOF mapping.
- PR4: Quadrature and basis tables.

## Goal
Define Galerkin data structures and allocate arrays that match Fortran storage layout.

---

## Scope and deliverables

### 1) FEM state structures
- Introduce `GalState` / `GalMatrices` (naming TBD) to hold system matrices, RHS, and metadata.

### 2) Allocation helpers
- Port allocation and initialization logic to match Fortran array sizes and banded layout.

---

## Fortran subroutines to convert
- `gal_alloc`
- `gal_dealloc`
- `gal_make_arrays`

---

## Detailed task list

### A) Source audit
- Identify the exact banded storage format and indexing in Fortran.
- Capture all array dimensions and ordering rules.

### B) Julia implementation
- Implement allocation helpers mirroring Fortran sizes and layout.
- Add explicit index mapping functions for banded storage.

### C) Tests
- Compare array sizes, banded layout, and index mapping to Fortran reference outputs.

---

## Acceptance criteria
- Julia structures faithfully represent Fortran storage.
- All arrays initialize with expected values.

---

## Out of scope
- Element assembly.
- Solver implementation.
