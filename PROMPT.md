# Generic PR agent prompt template

Use this prompt template for any PR in the RDCON → Julia conversion. Replace {{PR_NUMBER}} with the PR number (e.g., 2, 3, 4).

---

You are working in the JPEC repository. Read the orientation and the PR instructions, then complete all tasks described for PR{{PR_NUMBER}}.

Required reading:
- [AGENTS_ORIENTATION.md](AGENTS_ORIENTATION.md)
- [PR{{PR_NUMBER}}.md](PR{{PR_NUMBER}}.md)

Instructions:
1) Summarize the goal and deliverables for PR{{PR_NUMBER}}.
2) Locate the Fortran subroutines listed in PR{{PR_NUMBER}} and identify their source files under src/DCON/rdcon_fortran/rdcon.
3) Implement the Julia equivalents under src/DCON (or the Galerkin submodule path defined in the PR file).
4) Add unit tests and integration tests that compare Julia outputs to Fortran reference fixtures generated in PR1.
5) Update or add any documentation required by PR{{PR_NUMBER}}.
6) Ensure all changes are minimal, focused, and consistent with existing style.
7) Provide a concise summary of edits and how to run the tests.

Success criteria:
- All tasks in [PR{{PR_NUMBER}}.md](PR{{PR_NUMBER}}.md) are completed.
- Tests pass and outputs match Fortran reference fixtures within tolerance.

