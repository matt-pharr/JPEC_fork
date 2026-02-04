# PR4 — Galerkin quadrature + integration helpers

## Completed work from prior PRs
- PR1: Fortran RDCON test harness, reference fixtures, and Julia comparison utilities.
- PR2: Hermite basis utilities and toolbox helpers.
- PR3: Grid and DOF mapping.

## Goal
Implement quadrature points/weights and precomputed Hermite tables for element integration.

---

## Scope and deliverables

### 1) Gauss–Legendre quadrature
- Generate nodes and weights on the reference element.
- Support configurable order.

### 2) Precomputed basis tables
- Evaluate Hermite basis and derivatives at quadrature points.
- Provide caches to reuse across elements.

---

## Fortran subroutines to convert
- `gal_gauss_quad`
- `gal_hermite`

---

## Detailed task list

### A) Source audit
- Confirm quadrature order and scaling in Fortran.
- Verify mapping between reference and physical coordinates.

### B) Julia implementation
- Implement quadrature generation and caching.
- Provide helper that returns basis/derivative tables.

### C) Tests
- Compare quadrature nodes/weights and basis tables to Fortran outputs.

---

## Acceptance criteria
- Quadrature and basis tables match Fortran within tolerance.
- APIs are reused by assembly routines in later PRs.

---

## Out of scope
- Any element assembly.
- Any matrix solves.
