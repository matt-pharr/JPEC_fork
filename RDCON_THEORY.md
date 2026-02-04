# THEORY: Galerkin/FEM integrator in RDCON (outer ideal regions)

This document explains the numerical method used in **RDCON** to solve the **outer-region, zero-frequency ideal-MHD** equations in the presence of **regular singular points** (often called *resonant surfaces*). The goal is to describe how the **Galerkin / finite-element** discretization is constructed and solved.

Scope notes:

- This is **only** about the *outer ideal regions* and the discretization/linear algebra used there.
- We intentionally **do not discuss** inner-region physics, asymptotic matching, dispersion relations, or how outer-region outputs are later used.
- We focus on what an implementer needs to reproduce the Fortran numerics in Julia: basis functions, weak form, element assembly, special treatment near singular surfaces, boundary terms, and the resulting matrix solve.

---

## 1. Problem in one line: solve a linear ODE system with singular points

In the outer region you solve a linear system (written schematically)

$$
\mathcal{L}\,u(w) = f(w),
$$

on a 1D coordinate $w\in[0,1]$ (magnetic axis to plasma boundary). Here:

- $u(w)$ is a *vector* of unknown radial functions (dimension $M$, often $M=2$ in reduced formulations, but the method is general).
- $\mathcal{L}$ is a *linear differential operator* derived from ideal-MHD energy principles (Hermitian/self-adjoint under an appropriate inner product).
- The operator has **regular singular points** at certain $w=w_s$ (the “resonant surfaces”): coefficients in $\mathcal{L}$ behave like $1/(w-w_s)$ or $1/(w-w_s)^2$, so generic solutions include a **large** (non–finite-energy) branch and a **small** (finite-energy) branch.

RDCON’s integrator is built around two ideas:

1. Use a **Galerkin** (weak-form) discretization so the singular structure is handled by integrals rather than pointwise evaluation.
2. Use **C¹-continuous Hermite cubics** in each element so both function values and first derivatives are continuous across element boundaries.

The discretization produces a **sparse banded complex linear system**.

---

## 2. Weak form / Galerkin statement

### 2.1 Scalar product

Given two vector functions $a(w), b(w)\in\mathbb{C}^M$, define

$$
(a,b)\;=\;\int_{0}^{1} a(w)^\dagger\,b(w)\,dw,
$$

where $\dagger$ is Hermitian transpose.

### 2.2 Galerkin projection

Choose a finite-dimensional subspace spanned by basis functions $\{A_i(w)\}_{i=1}^n$, each $A_i:\,[0,1]\to\mathbb{C}^M$. Expand

$$
u(w) \approx \sum_{j=1}^{n} c_j\,A_j(w),
$$

with unknown coefficients $c_j\in\mathbb{C}$ (or block coefficients if you store vector unknowns per basis).

Galerkin discretization enforces the residual orthogonality:

$$
(A_i,\,\mathcal{L}u - f) = 0,\qquad i=1,\ldots,n,
$$

which yields a linear system

$$
\sum_{j=1}^n (A_i,\mathcal{L}A_j)\,c_j = (A_i,f).
$$

### 2.3 Integration by parts and boundary terms

In practice, $\mathcal{L}$ contains first- and second-derivative terms. RDCON rewrites $(A_i,\mathcal{L}A_j)$ so that the highest derivatives act symmetrically, integrating by parts as needed. This has two concrete consequences for implementation:

1. **Element matrices** are built from integrals of basis functions and their derivatives (typically up to first derivative after integrating by parts).
2. **Boundary terms** appear at $w=0$ and $w=1$. For fixed-boundary problems they are often set to zero by the boundary conditions; for free-boundary problems they contribute additional terms (e.g., vacuum response). The assembly must therefore allow optional boundary contributions on the last element.

---

## 3. Standard elements: C¹ Hermite cubic basis (normal elements)

### 3.1 Why Hermite cubics?

Crossing a singular surface while keeping the physically admissible branch typically requires tracking both the function and its derivative. RDCON uses **Hermite cubic shape functions** on each element because:

- They provide **C¹ continuity**: both $u$ and $u'$ are continuous across element interfaces.
- They are 4th-order accurate for smooth problems and behave well with nonuniform grids.
- Each element carries **four** scalar shape functions; for a vector unknown of dimension $M$, the element has $4M$ local degrees of freedom.

### 3.2 Reference element and mapping

Let element $e$ span $[w_L,w_R]$ with $h=w_R-w_L$. Map to a reference coordinate $\xi\in[0,1]$:

$$
w(\xi)=w_L + h\xi.
$$

Derivatives transform as

$$
\frac{d}{dw} = \frac{1}{h}\frac{d}{d\xi}.
$$

### 3.3 Hermite cubic shape functions

On $\xi\in[0,1]$, the standard Hermite cubics are:

- Function-value shapes:
  - $H_{00}(\xi)=2\xi^3-3\xi^2+1$ (value at left node)
  - $H_{10}(\xi)=-2\xi^3+3\xi^2$ (value at right node)

- Derivative shapes (scaled by $h$ in the usual convention):
  - $H_{01}(\xi)=\xi^3-2\xi^2+\xi$ (derivative at left node)
  - $H_{11}(\xi)=\xi^3-\xi^2$ (derivative at right node)

A scalar function on the element is approximated as

$$
u_e(\xi) = u_L\,H_{00}(\xi) + (h u'_L)\,H_{01}(\xi) + u_R\,H_{10}(\xi) + (h u'_R)\,H_{11}(\xi).
$$

For a vector unknown $u\in\mathbb{C}^M$, apply this componentwise.

### 3.4 Local DOF ordering (recommended)

For element $e$, a practical local ordering is:

1. all components of $u_L$
2. all components of $u'_L$ (or the scaled $h u'_L$)
3. all components of $u_R$
4. all components of $u'_R$

This ordering makes it easier to build block element matrices and to assemble into a banded global system.

---

## 4. Special treatment near singular surfaces

A key difficulty is that near $w=w_s$ the operator admits two local behaviors (a “small” admissible branch and a “large” branch). Standard polynomial elements alone can represent the admissible solution, but convergence can be slow and numerical contamination by the large branch can occur.

RDCON improves robustness by inserting **two special elements** near each singular surface:

1. **Resonant element (R element)**: augments the polynomial basis with an additional non-polynomial basis function constructed from the known local “small” singular behavior.
2. **Extension element (E element)**: connects that additional basis smoothly back to the standard Hermite basis by forcing it (and its first derivative) to go to zero at the interface with the neighboring normal element.

Conceptually, this is an *enrichment* of the finite element space in a small neighborhood of each singular surface.

### 4.1 Normal element (N element)

A normal element contains only the 4 Hermite cubics per scalar component.

### 4.2 Resonant element (R element): basis enrichment

In a resonant element, the basis is

$$
\{H_{00},H_{01},H_{10},H_{11}\}\;\cup\;\{\phi_\text{res}\},
$$

where $\phi_\text{res}(w)$ is the *additional basis function* capturing the local singular behavior (the “small” branch). This function is not a polynomial; it is typically built from a local power series around $w_s$ (or an equivalent analytic construction).

Implementation implication:
- The local element stiffness/mass-like matrices gain **one extra row/column per enriched component** (often one scalar enrichment per singular surface per parity/channel; in practice the enrichment structure is code-specific).
- The global matrix bandwidth becomes **nonuniform** near these enriched elements.

### 4.3 Extension element (E element): smooth truncation of the resonant basis

The additional basis $\phi_\text{res}$ is meant to influence only the neighborhood of the singular surface. The extension element introduces an additional basis function $\phi_\text{ext}$ that:

- matches $\phi_\text{res}$ and $\phi'_\text{res}$ at the interface between the R and E elements, and
- vanishes (value and first derivative) at the interface between the E element and the next normal element.

A practical way to build $\phi_\text{ext}$ is to express it as a linear combination of Hermite cubics on the E element using the required endpoint value/derivative constraints. For example, if the E element is to the right of $w_s$, one can set

$$
\phi_\text{ext}(w) = \phi_\text{res}(w_L)\,H_{00}(\xi) + (h\phi'_\text{res}(w_L))\,H_{01}(\xi),
$$

so it matches at the left endpoint and decays smoothly to zero at the right endpoint due to the Hermite structure.

Implementation implication:
- The E element is also enriched by **one extra basis function**, but unlike in the R element, it is expressed via Hermite cubics and is straightforward to evaluate at quadrature points.

---

## 5. Quadrature and element integrals

The entries of the global matrix are integrals of the form

$$
(A_i,\mathcal{L}A_j)=\int_{w_L}^{w_R} A_i(w)^\dagger\,\mathcal{L}A_j(w)\,dw
$$

(or after integrating by parts, combinations of $A_i, A_i'$ with coefficient matrices).

### 5.1 Gauss–Legendre quadrature on each element

For each element, map to $\xi\in[0,1]$ and use Gauss–Legendre points $\{\xi_q,\,\omega_q\}_{q=1}^{N_q}$. Then

$$
\int_{w_L}^{w_R} g(w)\,dw \approx h\sum_{q=1}^{N_q} \omega_q\,g(w(\xi_q)).
$$

In implementation:

- Precompute Hermite shapes and derivatives at quadrature points.
- Evaluate equilibrium-dependent coefficient matrices (from splines) at the same points.
- Accumulate local element matrices by looping over quadrature points.

### 5.2 Non-polynomial / non-analytic basis pieces

When enriched basis functions are defined via series or other special forms, their contributions to integrals may not be well represented by fixed Gauss–Legendre quadrature at low order. A robust strategy is:

- still use Gauss–Legendre for integrands built from smooth polynomials and spline-evaluated coefficients;
- for integrands involving the non-polynomial resonant basis, either:
  - increase quadrature order locally, or
  - use adaptive integration on that element only.

Which is used depends on how $\phi_\text{res}$ is represented in your codebase.

---

## 6. Global assembly: from element matrices to a banded system

### 6.1 Local-to-global DOF mapping

Each normal element shares its endpoint DOFs with neighbors (value and derivative continuity). Thus the global DOFs correspond to:

- $u(w_k)$ at each grid node $w_k$
- $u'(w_k)$ at each grid node $w_k$

For $N_\text{nodes}$ nodes and $M$ components, that is typically $2MN_\text{nodes}$ global unknowns, plus additional unknowns for each enriched basis function in R/E elements.

Define a mapping `gidx(e, local_dof)` → global index. Then the standard assembly is:

$$
K[g_i,g_j] \mathrel{+}= K^{(e)}[i,j],\qquad
b[g_i] \mathrel{+}= b^{(e)}[i].
$$

### 6.2 Sparsity / bandwidth structure

Because each element couples only DOFs at its two endpoints (and possibly one extra enriched DOF), the global matrix is **banded**:

- Normal elements produce a consistent bandwidth (coupling node $k$ to $k\pm1$).
- Resonant/extension elements add additional couplings to the enriched DOF, increasing bandwidth locally.

In Fortran, this is often stored in LAPACK banded formats. In Julia, you can choose:

- explicit banded storage (`BandedMatrices.jl`), or
- sparse CSC (`SparseArrays`) if you want flexibility, or
- a custom block-banded type (best performance, more work).

If you want to replicate Fortran behavior closely, block-banded or banded storage is usually the right target.

---

## 7. Boundary conditions and how they enter the discrete system

### 7.1 Axis boundary at $w=0$

Common axis conditions are regularity constraints; many implementations enforce a subset like:

- $u(0)=0$ for certain components (or a linear relation between value/derivative).

In a FEM/Galerkin setting, boundary conditions are typically enforced by one of:

- **Dirichlet elimination**: remove the constrained DOFs and modify RHS.
- **Row/column replacement**: set the equation to enforce the constraint directly.
- **Basis restriction**: choose basis functions that automatically satisfy the constraint (e.g., drop even/odd basis in the first cell in symmetric coordinates; details depend on coordinate choice).

RDCON-style Hermite FEM often uses elimination/replacement because it is straightforward in banded solvers.

### 7.2 Plasma boundary at $w=1$: fixed vs free boundary

- Fixed boundary: a condition such as $u(1)=0$ (or a linear constraint on boundary displacement) is applied similarly to axis Dirichlet constraints.

- Free boundary: boundary terms from integration by parts do not vanish and may be supplemented by a vacuum response operator. Discretely, this appears as an additional contribution to the bilinear form involving only the boundary DOFs (those associated with $w=1$). Implementation-wise, you add a small block to the last node’s portion of the global matrix.

The key design point: make boundary contributions a modular add-on during assembly.

---

## 8. Solving strategy in practice

For a single right-hand side $f(w)$, the end product is a complex linear system

$$
K\,x=b,
$$

where $x$ holds all DOFs (nodal values, nodal derivatives, and enriched coefficients).

Typical steps:

1. Build grid nodes $w_k$, including packed nodes near singular surfaces.
2. Build element list, tagging each element as N/R/E.
3. For each element:
   - compute quadrature points $w_q$,
   - evaluate coefficient matrices from equilibrium splines at $w_q$,
   - evaluate basis functions (Hermite + any enriched function) and derivatives,
   - accumulate the local element matrix and vector,
   - assemble into global $K, b$.
4. Apply boundary conditions (axis and boundary).
5. Solve using an appropriate linear solver:
   - banded Cholesky / LU if Hermitian positive-definite is guaranteed,
   - general banded LU if not,
   - sparse direct solver if using sparse CSC.

Because the continuous operator is Hermitian under the correct inner product, the discrete matrix is often Hermitian as well, but enriched elements and boundary handling can complicate this. In a Julia port, plan to support a general complex banded solve first; optimize later if Hermitian structure is preserved.

---

## Appendix: What the papers say in one sentence (for traceability)

- RDCON uses FEM with Hermite cubics to obtain C¹ continuity and introduces resonant/extension elements with additional basis functions near singular surfaces to represent the small singular behavior while keeping smooth connections to normal elements.
- The Galerkin method can be viewed as expanding in basis functions, taking inner products to obtain a banded matrix system, and solving it efficiently.
