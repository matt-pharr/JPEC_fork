# PR2 — Toolbox + Hermite basis utilities

## Completed work from prior PRs
- PR1: Fortran RDCON test harness, reference fixtures, and Julia comparison utilities.

## Goal
Port the core Hermite cubic basis and helper utilities used by RDCON’s Galerkin/FEM assembly.

---

## Scope and deliverables

### 1) Hermite basis evaluation
- Implement Hermite cubic basis functions and first derivatives on the reference element.
- Support vectorized evaluation over quadrature points.

### 2) Utility helpers
- Port `toolbox_preflatcof` and any coefficient helpers used to flatten/scale basis values.

### 3) API design
- Define a minimal public API for Galerkin basis evaluation to be reused by later PRs.

---

## Fortran subroutines to convert
- `toolbox_hermite`
- `toolbox_preflatcof`

---

## Detailed task list

### A) Source audit
- Inspect `toolbox.f` in Fortran RDCON for basis definitions, scaling conventions, and ordering.
- Identify whether derivatives are scaled by element size (h) or physical coordinates.

### B) Julia implementation
- Create `src/DCON/Galerkin/Toolbox.jl` (or similar) with:
  - `hermite_basis(ξ)` → values
  - `hermite_basis_deriv(ξ)` → derivatives
  - helper to assemble packed arrays in the same ordering as Fortran

### C) Unit tests
- Compare basis values/derivatives at multiple `ξ` points against Fortran outputs.
- Validate ordering and scaling (including element-size scaling).

### D) Documentation
- Add brief usage notes for basis APIs and scaling conventions.

---

## Acceptance criteria
- Hermite basis values and derivatives match Fortran outputs within tolerance.
- Public API is stable and reused by the next PRs.

---

## Out of scope
- Grid/element mapping.
- Galerkin assembly.
- Any matrix solve logic.
