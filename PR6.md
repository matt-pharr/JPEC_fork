# PR6 — Galerkin assembly: RHS

## Completed work from prior PRs
- PR1: Fortran RDCON test harness, reference fixtures, and Julia comparison utilities.
- PR2: Hermite basis utilities and toolbox helpers.
- PR3: Grid and DOF mapping.
- PR4: Quadrature and basis tables.
- PR5: Galerkin data structures and allocation.

## Goal
Implement RHS assembly over elements using quadrature and basis tables.

---

## Scope and deliverables

### 1) RHS element integrals
- Compute element RHS contributions using Hermite basis and equilibrium coefficients.

### 2) Global RHS assembly
- Map local contributions into the global RHS vector using DOF mapping.

---

## Fortran subroutines to convert
- `gal_assemble_rhs`

---

## Detailed task list

### A) Source audit
- Identify coefficient evaluations used by RHS assembly.
- Confirm integration order and scaling.

### B) Julia implementation
- Add `assemble_rhs!` with local element loops and global accumulation.

### C) Tests
- Compare assembled RHS vector against Fortran fixtures for the reference cases.

---

## Acceptance criteria
- RHS assembly matches Fortran within tolerance for reference inputs.

---

## Out of scope
- Matrix assembly.
- Solver integration.
