# PR8 — Resonant element enrichment (R elements)

## Completed work from prior PRs
- PR1: Fortran RDCON test harness, reference fixtures, and Julia comparison utilities.
- PR2: Hermite basis utilities and toolbox helpers.
- PR3: Grid and DOF mapping.
- PR4: Quadrature and basis tables.
- PR5: Galerkin data structures and allocation.
- PR6: RHS assembly.
- PR7: Matrix assembly for normal elements.

## Goal
Add resonant (R) element basis enrichment and assembly.

---

## Scope and deliverables

### 1) Resonant basis evaluation
- Implement non-polynomial resonant basis functions (small-branch enrichment).

### 2) R-element assembly
- Add enriched RHS and matrix contributions for R elements.

---

## Fortran subroutines to convert
- `gal_extension`
- `gal_get_fkg` (if it provides resonant coefficients)

---

## Detailed task list

### A) Source audit
- Identify how the resonant basis is constructed and normalized.
- Determine additional DOFs added for R elements.

### B) Julia implementation
- Implement resonant basis evaluation.
- Extend assembly routines to handle enriched R elements.

### C) Tests
- Compare R-element local matrices/RHS and global contributions to Fortran fixtures.

---

## Acceptance criteria
- R-element contributions match Fortran within tolerance.

---

## Out of scope
- Extension (E) elements.
- Global solve.
