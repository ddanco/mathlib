/-
Copyright (c) 2022 Alexander Bentkamp. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alexander Bentkamp
-/
import linear_algebra.matrix.spectrum
import linear_algebra.quadratic_form.basic

/-! # Positive Definite Matrices

This file defines positive definite matrices and connects this notion to positive definiteness of
quadratic forms.

## Main definition

 * `matrix.pos_def` : a matrix `M : matrix n n R` is positive definite if it is hermitian
   and `xᴴMx` is greater than zero for all nonzero `x`.

-/

namespace matrix

variables {𝕜 : Type*} [is_R_or_C 𝕜] {n : Type*} [fintype n]

open_locale matrix

/-- A matrix `M : matrix n n R` is positive definite if it is hermitian
   and `xᴴMx` is greater than zero for all nonzero `x`. -/
def pos_def (M : matrix n n 𝕜) :=
M.is_hermitian ∧ ∀ x : n → 𝕜, x ≠ 0 → 0 < is_R_or_C.re (dot_product (star x) (M.mul_vec x))

lemma pos_def.is_hermitian {M : matrix n n 𝕜} (hM : M.pos_def) : M.is_hermitian := hM.1

lemma pos_def.transpose {M : matrix n n 𝕜} (hM : M.pos_def) : Mᵀ.pos_def :=
begin
  refine ⟨is_hermitian.transpose hM.1, λ x hx, _⟩,
  convert hM.2 (star x) (star_ne_zero.2 hx) using 2,
  rw [mul_vec_transpose, matrix.dot_product_mul_vec, star_star, dot_product_comm]
end

lemma pos_def_of_to_quadratic_form' [decidable_eq n] {M : matrix n n ℝ}
  (hM : M.is_symm) (hMq : M.to_quadratic_form'.pos_def) :
  M.pos_def :=
begin
  refine ⟨hM, λ x hx, _⟩,
  simp only [to_quadratic_form', quadratic_form.pos_def, bilin_form.to_quadratic_form_apply,
    matrix.to_bilin'_apply'] at hMq,
  apply hMq x hx,
end

lemma pos_def_to_quadratic_form' [decidable_eq n] {M : matrix n n ℝ} (hM : M.pos_def) :
  M.to_quadratic_form'.pos_def :=
begin
  intros x hx,
  simp only [to_quadratic_form', bilin_form.to_quadratic_form_apply, matrix.to_bilin'_apply'],
  apply hM.2 x hx,
end

namespace pos_def

variables {M : matrix n n ℝ} (hM : M.pos_def)
include hM

lemma det_pos [decidable_eq n] : 0 < det M :=
begin
  rw hM.is_hermitian.det_eq_prod_eigenvalues,
  apply finset.prod_pos,
  intros i _,
  rw hM.is_hermitian.eigenvalues_eq,
  apply hM.2 _ (λ h, _),
  have h_det : (hM.is_hermitian.eigenvector_matrix)ᵀ.det = 0,
    from matrix.det_eq_zero_of_row_eq_zero i (λ j, congr_fun h j),
  simpa only [h_det, not_is_unit_zero] using
    is_unit_det_of_invertible hM.is_hermitian.eigenvector_matrixᵀ,
end

end pos_def

end matrix

namespace quadratic_form

variables {n : Type*} [fintype n]

lemma pos_def_of_to_matrix'
  [decidable_eq n] {Q : quadratic_form ℝ (n → ℝ)} (hQ : Q.to_matrix'.pos_def) :
  Q.pos_def :=
begin
  rw [←to_quadratic_form_associated ℝ Q,
      ←bilin_form.to_matrix'.left_inv ((associated_hom _) Q)],
  apply matrix.pos_def_to_quadratic_form' hQ
end

lemma pos_def_to_matrix' [decidable_eq n] {Q : quadratic_form ℝ (n → ℝ)} (hQ : Q.pos_def) :
  Q.to_matrix'.pos_def :=
begin
  rw [←to_quadratic_form_associated ℝ Q,
    ←bilin_form.to_matrix'.left_inv ((associated_hom _) Q)] at hQ,
  apply matrix.pos_def_of_to_quadratic_form' (is_symm_to_matrix' Q) hQ,
end

end quadratic_form

namespace matrix

variables {𝕜 : Type*} [is_R_or_C 𝕜] {n : Type*} [fintype n]

/-- A positive definite matrix `M` induces an inner product `⟪x, y⟫ = xᴴMy`. -/
noncomputable def inner_product_space.of_matrix
  {M : matrix n n 𝕜} (hM : M.pos_def) : inner_product_space 𝕜 (n → 𝕜) :=
inner_product_space.of_core
{ inner := λ x y, dot_product (star x) (M.mul_vec y),
  conj_sym := λ x y, by
    rw [star_dot_product, star_ring_end_apply, star_star, star_mul_vec,
      dot_product_mul_vec, hM.is_hermitian.eq],
  nonneg_re := λ x,
    begin
      by_cases h : x = 0,
      { simp [h] },
      { exact le_of_lt (hM.2 x h) }
    end,
  definite := λ x hx,
    begin
      by_contra' h,
      simpa [hx, lt_self_iff_false] using hM.2 x h,
    end,
  add_left := by simp only [star_add, add_dot_product, eq_self_iff_true, forall_const],
  smul_left := λ x y r, by rw [← smul_eq_mul, ←smul_dot_product, star_ring_end_apply, ← star_smul] }

end matrix
