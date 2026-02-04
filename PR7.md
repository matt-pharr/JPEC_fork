# PR7 — Galerkin assembly: matrix core (normal elements)

## Completed work from prior PRs
- PR1: Fortran RDCON test harness, reference fixtures, and Julia comparison utilities.
- PR2: Hermite basis utilities and toolbox helpers.
- PR3: Grid and DOF mapping.
- PR4: Quadrature and basis tables.
- PR5: Galerkin data structures and allocation.
- PR6: RHS assembly.

## Goal
Assemble the global FEM matrix for normal (N) elements.

---

## Scope and deliverables

### 1) Element matrix computation
- Compute local stiffness/mass-like matrices for N elements.

### 2) Global assembly
- Insert local matrices into the global banded structure.

---

## Fortran subroutines to convert
- `gal_assemble_mat`
- `gal_diagnose_mat`

---

## Detailed task list

### A) Source audit
- Determine coefficient matrices and element integrals used for N elements.
- Capture any special scaling or boundary handling at this stage.

### B) Julia implementation
- Implement `assemble_mat!` for N elements.
- Add diagnostics mirroring Fortran’s matrix summaries.

### C) Tests
- Compare element matrices and the global banded matrix against Fortran outputs.

---

## Acceptance criteria
- Global matrix values match Fortran for reference inputs.
- Diagnostics align with Fortran output.

---

## Out of scope
- R/E elements.
- Solver integration.
