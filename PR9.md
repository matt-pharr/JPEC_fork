# PR9 — Extension elements (E elements)

## Completed work from prior PRs
- PR1: Fortran RDCON test harness, reference fixtures, and Julia comparison utilities.
- PR2: Hermite basis utilities and toolbox helpers.
- PR3: Grid and DOF mapping.
- PR4: Quadrature and basis tables.
- PR5: Galerkin data structures and allocation.
- PR6: RHS assembly.
- PR7: Matrix assembly for normal elements.
- PR8: Resonant element enrichment.

## Goal
Implement extension (E) elements to smoothly connect resonant bases to normal elements.

---

## Scope and deliverables

### 1) Extension basis construction
- Build extension basis functions that match resonant basis at one end and vanish at the other.

### 2) E-element assembly
- Add E-element contributions to RHS and matrix assembly.

---

## Fortran subroutines to convert
- `gal_extension` (remaining logic)
- `gal_set_boundary` (if tied to element boundary constraints)

---

## Detailed task list

### A) Source audit
- Confirm boundary conditions and basis constraints for E elements.

### B) Julia implementation
- Implement E-element basis and integrate into assembly.

### C) Tests
- Compare E-element local matrices/RHS and global contributions to Fortran fixtures.

---

## Acceptance criteria
- E-element contributions match Fortran within tolerance.

---

## Out of scope
- Global solve and outputs.
