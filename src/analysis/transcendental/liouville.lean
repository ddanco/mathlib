/-
Copyright (c) 2020 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang
-/

import data.real.irrational
import data.polynomial.denoms_clearable
import ring_theory.algebraic
import topology.algebra.polynomial
import analysis.calculus.mean_value

/-!
# Liouville's theorem

This file contains the proof of Liouville's theorem stating that all Liouville numbers are
transcendental.
-/

lemma nat.mul_lt_mul_pow_succ {n : ℕ} {a q : ℕ} (a0 : 0 < a) (q1 : 1 < q) :
  n * q < a * q ^ (n + 1) :=
begin
  rw [pow_succ', ← mul_assoc, mul_lt_mul_right (zero_lt_one.trans q1)],
  exact lt_mul_of_one_le_of_lt' (nat.succ_le_iff.mpr a0) (nat.lt_pow_self q1 n),
end

lemma int.mul_lt_mul_pow_succ {n : ℕ} {a q : ℤ} (a0 : 0 < a) (q1 : 1 < q) :
  (n : ℤ) * q < a * q ^ (n + 1) :=
begin
  lift a to ℕ using a0.le,
  lift q to ℕ using zero_le_one.trans q1.le,
  rw [← int.coe_nat_mul, ← int.coe_nat_pow, ← int.coe_nat_mul, int.coe_nat_lt],
  exact nat.mul_lt_mul_pow_succ (int.coe_nat_pos.mp a0) (int.coe_nat_lt.mp q1),
end

lemma int.eq_zero_iff_abs_lt_one {a : ℤ} : abs a < 1 ↔ a = 0 :=
⟨λ a0, le_antisymm (int.le_of_lt_add_one (by { rw zero_add, exact (abs_lt.mp a0).2 }))
  (by { rw ← add_left_neg (0 : ℤ), exact int.add_one_le_iff.mpr (abs_lt.mp a0).1 }),
  λ a0, by { rw [a0, abs_zero], exact zero_lt_one }⟩

namespace real
/--
A Liouville number `x` is a number such that for every natural number `n`, there exists `a, b ∈ ℤ`
with `b > 1` such that `0 < |x - a/b| < 1/bⁿ`.
-/
def is_liouville (x : ℝ) := ∀ n : ℕ, ∃ a b : ℤ,
  1 < b ∧ x ≠ a / b ∧ abs (x - a / b) < 1 / b ^ n

lemma irrational_of_is_liouville {x : ℝ} (h : is_liouville x) : irrational x :=
begin
  rintros ⟨⟨a, b, bN0, cop⟩, rfl⟩,
  change (is_liouville (a / b)) at h,
  rcases h (b + 1) with ⟨p, q, q1, a0, a1⟩,
  have qR0 : (0 : ℝ) < q := int.cast_pos.mpr (zero_lt_one.trans q1),
  have b0 : (b : ℝ) ≠ 0 := ne_of_gt (nat.cast_pos.mpr bN0),
  have bq0 : (0 : ℝ) < b * q := mul_pos (nat.cast_pos.mpr bN0) qR0,
  rw [div_sub_div _ _ b0 (ne_of_gt qR0), abs_div, div_lt_div_iff (abs_pos.mpr (ne_of_gt bq0))
    (pow_pos qR0 _), abs_of_pos bq0, one_mul] at a1,
  rw [← int.cast_pow, ← int.cast_mul, ← int.cast_coe_nat, ← int.cast_mul, ← int.cast_mul,
    ← int.cast_sub, ← int.cast_abs, ← int.cast_mul, int.cast_lt] at a1,
  rw [ne.def, div_eq_div_iff b0 (ne_of_gt qR0), mul_comm ↑p, ← sub_eq_zero_iff_eq] at a0,
  rw [← int.cast_coe_nat, ← int.cast_mul, ← int.cast_mul, ← int.cast_sub, int.cast_eq_zero] at a0,
  exact not_le.mpr a1 (int.mul_lt_mul_pow_succ (abs_pos.mpr a0) q1).le,
end

lemma not_liouville_zero : ¬ is_liouville 0 :=
λ h, irrational_of_is_liouville h ⟨0, rat.cast_zero⟩

end real

--use d ^ m = b ^ m
lemma pow_mul_lt_base {R : Type*} [linear_ordered_semiring R] {a b c d : R}
  (c0 : 0 ≤ c) (b0 : 0 ≤ b) (d0 : 0 ≤ d) (cd : c ≤ d) (ba : d * b * a < 1) :
  c * b * a < 1 :=
begin
  by_cases a0 : a ≤ 0,
  { refine lt_of_le_of_lt _ zero_lt_one,
    exact mul_nonpos_of_nonneg_of_nonpos (mul_nonneg c0 ( b0)) a0 },
  { refine lt_of_le_of_lt _ ba,
    refine mul_le_mul _ rfl.le _ _,
    { exact mul_le_mul_of_nonneg_right cd b0 },
    { rwa not_le at a0,
      exact a0.le },
    exact mul_nonneg d0 b0 }
end

lemma pow_le_pow_of_base_le {R : Type*} [ordered_semiring R] {a b : R} {n : ℕ}
  (a0 : 0 ≤ a) (ab : a ≤ b) :
  a ^ n ≤ b ^ n :=
pow_le_pow_of_le_left a0 ab n

lemma pow_mul_lt {R : Type*} [linear_ordered_field R] {a b c d : R} {m n : ℕ} (c0 : 0 < c)
  (d0 : 0 < d) (db : d ≤ b) (dc : 1 ≤ d ^ m * c) (ba : b ^ (m + n) * a < 1) :
  b ^ n * a < c :=
begin
  rw [← mul_one c, ← div_lt_iff' c0, mul_div_assoc, mul_div_comm, mul_comm, ← mul_one_div,
    mul_comm (b ^ n)],
  rw [pow_add] at ba,
  refine pow_mul_lt_base (one_div_pos.mpr c0).le _ _ _ ba;
  try { exact pow_nonneg (d0.le.trans db) _ },
  { rw [← mul_one (1 : R), ← div_le_iff c0, mul_one] at dc,
    exact dc.trans (pow_le_pow_of_le_left d0.le db _) }
/-
  rw one_div_le at dc,
  apply (one_div_pos.mp c0).le
  refine ((lt_div_iff' _).mpr ba).trans_le ((div_le_iff' _).mpr (dc.trans _)),
  any_goals { exact pow_pos (d0.trans_le db) m },
  exact (mul_le_mul_right c0).mpr (pow_le_pow_of_le_left d0.le db m),
-/
end

--use d ^ m = b ^ m
lemma pow_mul_lt_two {R : Type*} [linear_ordered_field R] {a b c : R} {m n : ℕ}
  (c0 : 0 ≤ c) (b0 : 0 ≤ b) (cb : c ≤ b ^ m) (ba : b ^ (m + n) * a < 1) :
  c * (b ^ n * a) < 1 :=
begin
  by_cases a0 : a ≤ 0,
  apply lt_of_le_of_lt _ zero_lt_one,
  rw ← mul_assoc,
  apply mul_nonpos_of_nonneg_of_nonpos (mul_nonneg c0 ( pow_nonneg b0 _)) a0,
  exact nontrivial_of_lt (b ^ (m + n) * a) 1 ba,

  rw [pow_add, mul_assoc] at ba,
  apply lt_of_le_of_lt _ ba,
  apply mul_le_mul _ rfl.le _ _,
  {
    apply cb.trans rfl.le,
  },
  {
    rw not_le at a0,
    apply mul_nonneg _ a0.le,apply pow_nonneg b0,
  },
  apply pow_nonneg b0,
end


lemma pow_mul_lt_three {R : Type*} [linear_ordered_field R] {a b c d : R} {m n : ℕ} (c0 : 0 < c)
  (d0 : 0 < d) (db : d ≤ b) (dc : 1 ≤ d ^ m * c) (ba : b ^ (m + n) * a < 1) :
  b ^ n * a < c :=
begin
  rw [← mul_one c, ← div_lt_iff' c0, mul_div_assoc, mul_div_comm, mul_comm, ← mul_one_div,
    mul_comm (b ^ n), mul_assoc],
  apply pow_mul_lt,
  rw [pow_add, mul_assoc] at ba,
  refine ((lt_div_iff' _).mpr ba).trans_le ((div_le_iff' _).mpr (dc.trans _)),
  any_goals { exact pow_pos (d0.trans_le db) m },
  exact (mul_le_mul_right c0).mpr (pow_le_pow_of_le_left d0.le db m),
end

open set ring_hom

namespace polynomial

-- going to denoms_clearable
lemma one_le_denom_pow_eval_rat {f : polynomial ℤ} {a b : ℤ}
  (b0 : (0 : ℝ) < b) (fab : eval ((a : ℝ) / b) (f.map (algebra_map ℤ ℝ)) ≠ 0) :
  (1 : ℝ) ≤ b ^ f.nat_degree * abs (eval ((a : ℝ) / b) (f.map (algebra_map ℤ ℝ))) :=
one_le_pow_mul_abs_eval_div b0 fab

end polynomial

section inequality_and_intervals

lemma le_mul_of_le_and {R : Type*} [linear_ordered_semiring R] {a b : R} (c : R)
  (ha   : 1 ≤ a)
  (key  : b ≤ 1 → 1 ≤ a * c ∧ c ≤ b) :
  1 ≤ a * b :=
begin
  by_cases A : b ≤ 1,
  { exact (key A).1.trans ((mul_le_mul_left (zero_lt_one.trans_le ha)).mpr (key A).2) },
  { rw ← mul_one (1 : R),
    exact mul_le_mul ha (not_le.mp A).le zero_le_one (zero_le_one.trans ha) }
end

lemma mem_Icc_iff_abs_le {R : Type*} [linear_ordered_add_comm_group R] {x y z : R} :
  abs (x - y) ≤ z ↔ y ∈ Icc (x - z) (x + z) :=
⟨λ h, ⟨sub_le.mp (abs_le.mp h).2, neg_le_sub_iff_le_add.mp (abs_le.mp h).1⟩,
 λ hy, abs_le.mpr ⟨neg_le_sub_iff_le_add.mpr hy.2, sub_le.mp hy.1⟩⟩

end inequality_and_intervals

--namespace is_liouville

open polynomial metric

lemma with_metr_max {Z N R : Type*} [metric_space R]
  {d : N → ℝ} {j : Z → N → R} {f : R → R} {α : R} {ε M : ℝ} {n : ℕ}
--denominators are positive
  (d0 : ∀ (a : N), 1 ≤ d a)
  (e0 : 0 < ε)
--function is Lipschitz at α
  (B : ∀ ⦃y : R⦄, y ∈ closed_ball α ε → dist (f α) (f y) ≤ (dist α y) * M)
--clear denominators
  (L : ∀ ⦃z : Z⦄, ∀ ⦃a : N⦄, j z a ∈ closed_ball α ε →
    (1 : ℝ) ≤ (d a) ^ n * dist (f α) (f (j z a))) :
  ∃ e : ℝ, 0 < e ∧ ∀ (z : Z), ∀ (a : N), 1 ≤ (d a) ^ n * (dist α (j z a) * e) :=
begin
  have me0 : 0 < max (1 / ε) M := lt_max_iff.mpr (or.inl (one_div_pos.mpr e0)),
  refine ⟨max (1 / ε) M, me0, λ z a, _⟩,
  refine le_mul_of_le_and (dist (f α) (f (j z a))) (one_le_pow_of_one_le (d0 a) _) (λ p, _),
  have jd : j z a ∈ closed_ball α ε := mem_closed_ball'.mp
    (((le_div_iff me0).mpr p).trans ((one_div_le me0 e0).mpr (le_max_left _ _))),
  exact ⟨L jd, (B jd).trans (mul_le_mul_of_nonneg_left (le_max_right (1 / ε) M) dist_nonneg)⟩,
end

lemma exists_pos_real_of_irrational_root {α : ℝ} (ha : irrational α)
  {f : polynomial ℤ} (f0 : f ≠ 0) (fa : eval α (map (algebra_map ℤ ℝ) f) = 0):
  ∃ ε : ℝ, 0 < ε ∧
    ∀ (a : ℤ), ∀ (b : ℕ), (1 : ℝ) ≤ (b.succ) ^ f.nat_degree * (abs (α - (a / (b.succ))) * ε) :=
begin
  set fR : polynomial ℝ := map (algebra_map ℤ ℝ) f,
  have ami : function.injective (algebra_map ℤ ℝ) :=
    λ _ _ A, by simpa only [ring_hom.eq_int_cast, int.cast_inj] using A,
  obtain fR0 : fR ≠ 0 := by simpa using (map_injective (algebra_map ℤ ℝ) ami).ne f0,
  have ar : α ∈ (fR.roots.to_finset : set ℝ) := finset.mem_coe.mpr (multiset.mem_to_finset.mpr $
    (mem_roots (fR0)).mpr (is_root.def.mpr fa)),
  obtain ⟨ζ, z0, U⟩ :=
    @exists_closed_ball_inter_eq_singleton_of_discrete _ _ _ discrete_of_t1_of_finite _ ar,
  obtain ⟨xm, ⟨h_x_max_range, hM⟩⟩ := is_compact.exists_forall_ge (@compact_Icc (α - ζ) (α + ζ))
    ⟨α, (sub_lt_self α z0).le, (lt_add_of_pos_right α z0).le⟩
    (continuous_abs.comp fR.derivative.continuous_aeval).continuous_on,
  apply @with_metr_max ℤ ℕ ℝ _ _ _ (λ y, eval y fR) α ζ (abs (eval xm fR.derivative)) _ _ z0
    (λ y hy, _) (λ z a hq, _),
  { exact (λ a, (le_add_iff_nonneg_left _).mpr a.cast_nonneg) }, --simp
  { rw [mul_comm],
    rw [closed_ball_Icc] at hy,
    refine convex.norm_image_sub_le_of_norm_deriv_le (λ _ _, fR.differentiable_at)
      (λ y h, by { rw fR.deriv, exact hM _ h }) (convex_Icc _ _) hy (mem_Icc_iff_abs_le.mp _),
    exact @mem_closed_ball_self ℝ _ α ζ (le_of_lt z0) },
  { show 1 ≤ (a + 1 : ℝ) ^ f.nat_degree * abs (eval α fR - eval (z / (a + 1)) fR),
    rw [fa, zero_sub, abs_neg],
    refine one_le_denom_pow_eval_rat (int.cast_pos.mpr (int.coe_nat_succ_pos a)) (λ hy, _),
    refine (irrational_iff_ne_rational α).mp ha z (a + 1) ((mem_singleton_iff.mp _).symm),
    rw ← U,
    refine ⟨hq, finset.mem_coe.mp (multiset.mem_to_finset.mpr _)⟩,
    exact (mem_roots (fR0)).mpr (is_root.def.mpr hy) }
end

open real

theorem transcendental_of_is_liouville {x : ℝ} (liouville_x : is_liouville x) :
  is_transcendental ℤ x :=
begin
  rintros ⟨f : polynomial ℤ, f0, ef0⟩,
  replace ef0 : (f.map (algebra_map ℤ ℝ)).eval x = 0, { rwa [aeval_def, ← eval_map] at ef0 },
  obtain ⟨A, hA, h⟩ :=
    exists_pos_real_of_irrational_root (irrational_of_is_liouville liouville_x) f0 ef0,
  rcases pow_unbounded_of_one_lt A (lt_add_one 1) with ⟨r, hn⟩,
  obtain ⟨a, b, b1, -, a1⟩ := liouville_x (r + f.nat_degree),
  have b0 : (0 : ℝ) < b := zero_lt_one.trans (by { rw ← int.cast_one, exact int.cast_lt.mpr b1 }),
  refine lt_irrefl ((b : ℝ) ^ f.nat_degree * abs (x - ↑a / ↑b)) _,
  refine ((_  : (b : ℝ) ^ f.nat_degree * abs (x - a / b) < 1 / A).trans_le _),
  { refine pow_mul_lt (one_div_pos.mpr hA) zero_lt_two _ _ ((lt_div_iff' (pow_pos b0 _)).mp a1),
    { exact int.cast_two.symm.le.trans (int.cast_le.mpr (int.add_one_le_iff.mpr b1)) },
    { rw [mul_one_div, (le_div_iff hA), one_mul],
      exact hn.le } },
  { lift b to ℕ using zero_le_one.trans b1.le,
    specialize h a b.pred,
    rwa [nat.succ_pred_eq_of_pos (zero_lt_one.trans _), ← mul_assoc, ← (div_le_iff hA)] at h,
    exact int.coe_nat_lt.mp b1 }
end
