# PR1 — Test harness + Fortran reference runners

## Goal
Establish a repeatable test harness that runs the Fortran RDCON executables on fixed inputs, captures outputs in a stable format, and enables Julia-side tests to compare against those reference outputs. This PR does not implement any Galerkin conversion yet; it only creates the infrastructure for 1:1 output comparisons.

---

## Scope and deliverables

### 1) Define reference test cases
- Select 1–2 minimal equilibria and inputs that run quickly and deterministically in Fortran RDCON.
- Record the exact input files (dcon.toml, equil.toml, vac.in, wall settings if any).
- Store test-case metadata (expected runtime, machine assumptions, any non-determinism notes).

### 2) Fortran build/run automation
- Add a reproducible build command for the RDCON Fortran code in src/DCON/rdcon_fortran/rdcon.
- Provide a scriptable runner that:
  - Builds the Fortran executable(s) once.
  - Executes them in a fixed working directory.
  - Captures stdout/stderr and key output files.
- Ensure the runner supports an offline mode that skips rebuilding if binaries are already present.

### 3) Reference output capture
- Define the reference output schema (HDF5/JLD2) for numeric data, including:
  - grid nodes
  - element metadata
  - assembled matrices/vectors (if available from Fortran outputs)
  - final solution vectors
  - diagnostic arrays
- Add a converter that maps Fortran output artifacts into the reference schema.
- Store reference outputs in a dedicated test fixtures directory.

### 4) Julia test utilities
- Add Julia helper functions to:
  - locate test fixtures
  - load reference outputs
  - compare arrays with configurable absolute/relative tolerances
  - generate comparison reports for CI logs
- Implement a standard comparison API to be reused by later PRs.

### 5) Initial integration test
- Add a Julia integration test that:
  - invokes the Fortran runner (or uses precomputed fixtures)
  - loads reference data
  - verifies the presence and shape of all expected outputs
  - performs a sanity comparison on a small subset of arrays (within tolerance)

### 6) Documentation and usage
- Document how to:
  - build and run the Fortran reference
  - update reference outputs
  - run the Julia tests locally
- Add troubleshooting notes for environment dependencies (compiler, netCDF, module loads).

---

## Detailed task list

### A) Test-case selection and fixture layout
- Choose two small RDCON inputs with short runtimes.
- Create a fixtures directory structure (e.g., test/test_data/rdcon_case_01, rdcon_case_02).
- Store all input files in each case directory.
- Add a metadata file describing assumptions and expected results.

### B) Fortran build and execution
- Test the build script at (src/DCON/rdcon_fortran/make_pharr_server.sh) for the agent machine.
- Ensure it produces a working RDCON executable.
- Create a run script that:
  - sets module environment if needed
  - runs the executable with the selected input case
  - writes outputs to a deterministic location

### C) Output normalization
- Identify which Fortran outputs are available for RDCON in this repository (netCDF, stdout, binary).
- Build a normalization step that:
  - converts outputs into a stable format
  - encodes complex arrays consistently
  - records metadata (version, git hash, build flags)

### D) Julia test utilities
- Implement:
  - reference loader (HDF5/JLD2)
  - comparison helper with tolerances per-array type
  - diff summary for failing tests

### E) Initial test
- Add a single Julia test that loads fixtures and validates array shapes and a small subset of values.
- The test should skip or xfail if Fortran outputs are unavailable and note the reason.

### F) CI considerations
- Decide whether Fortran builds run in CI or only locally.
- If CI builds are not feasible, ensure tests can run using precomputed fixtures only.

---

## Acceptance criteria
- A user can run a single command to build and execute Fortran RDCON for the chosen test cases.
- Reference outputs are stored in a stable format and can be loaded in Julia.
- A Julia test validates reference outputs and passes on a supported environment.
- Documentation explains how to reproduce and update fixtures.

---

## Out of scope for PR1
- Any Galerkin/FEM conversion or numerical implementation in Julia.
- Any changes to Julia DCON solver behavior.
- Any performance optimization work.
