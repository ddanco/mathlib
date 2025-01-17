/-
Copyright (c) 2021 Thomas Browning. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Browning
-/

import data.finite.card
import group_theory.quotient_group

/-!
# Index of a Subgroup

In this file we define the index of a subgroup, and prove several divisibility properties.
Several theorems proved in this file are known as Lagrange's theorem.

## Main definitions

- `H.index` : the index of `H : subgroup G` as a natural number,
  and returns 0 if the index is infinite.
- `H.relindex K` : the relative index of `H : subgroup G` in `K : subgroup G` as a natural number,
  and returns 0 if the relative index is infinite.

# Main results

- `card_mul_index` : `nat.card H * H.index = nat.card G`
- `index_mul_card` : `H.index * fintype.card H = fintype.card G`
- `index_dvd_card` : `H.index ∣ fintype.card G`
- `index_eq_mul_of_le` : If `H ≤ K`, then `H.index = K.index * (H.subgroup_of K).index`
- `index_dvd_of_le` : If `H ≤ K`, then `K.index ∣ H.index`
- `relindex_mul_relindex` : `relindex` is multiplicative in towers

-/

namespace subgroup

open_locale big_operators cardinal

variables {G : Type*} [group G] (H K L : subgroup G)

/-- The index of a subgroup as a natural number, and returns 0 if the index is infinite. -/
@[to_additive "The index of a subgroup as a natural number,
and returns 0 if the index is infinite."]
noncomputable def index : ℕ :=
nat.card (G ⧸ H)

/-- The relative index of a subgroup as a natural number,
  and returns 0 if the relative index is infinite. -/
@[to_additive "The relative index of a subgroup as a natural number,
  and returns 0 if the relative index is infinite."]
noncomputable def relindex : ℕ :=
(H.subgroup_of K).index

@[to_additive] lemma index_comap_of_surjective {G' : Type*} [group G'] {f : G' →* G}
  (hf : function.surjective f) : (H.comap f).index = H.index :=
begin
  letI := quotient_group.left_rel H,
  letI := quotient_group.left_rel (H.comap f),
  have key : ∀ x y : G', setoid.r x y ↔ setoid.r (f x) (f y),
  { simp only [quotient_group.left_rel_apply],
    exact λ x y, iff_of_eq (congr_arg (∈ H) (by rw [f.map_mul, f.map_inv])) },
  refine cardinal.to_nat_congr (equiv.of_bijective (quotient.map' f (λ x y, (key x y).mp)) ⟨_, _⟩),
  { simp_rw [←quotient.eq'] at key,
    refine quotient.ind' (λ x, _),
    refine quotient.ind' (λ y, _),
    exact (key x y).mpr },
  { refine quotient.ind' (λ x, _),
    obtain ⟨y, hy⟩ := hf x,
    exact ⟨y, (quotient.map'_mk' f _ y).trans (congr_arg quotient.mk' hy)⟩ },
end

@[to_additive] lemma index_comap {G' : Type*} [group G'] (f : G' →* G) :
  (H.comap f).index = H.relindex f.range :=
eq.trans (congr_arg index (by refl))
  ((H.subgroup_of f.range).index_comap_of_surjective f.range_restrict_surjective)

variables {H K L}

@[to_additive relindex_mul_index] lemma relindex_mul_index (h : H ≤ K) :
  H.relindex K * K.index = H.index :=
((mul_comm _ _).trans (cardinal.to_nat_mul _ _).symm).trans
  (congr_arg cardinal.to_nat (equiv.cardinal_eq (quotient_equiv_prod_of_le h))).symm

@[to_additive] lemma index_dvd_of_le (h : H ≤ K) : K.index ∣ H.index :=
dvd_of_mul_left_eq (H.relindex K) (relindex_mul_index h)

@[to_additive] lemma relindex_dvd_index_of_le (h : H ≤ K) : H.relindex K ∣ H.index :=
dvd_of_mul_right_eq K.index (relindex_mul_index h)

@[to_additive] lemma relindex_subgroup_of (hKL : K ≤ L) :
  (H.subgroup_of L).relindex (K.subgroup_of L) = H.relindex K :=
((index_comap (H.subgroup_of L) (inclusion hKL)).trans (congr_arg _ (inclusion_range hKL))).symm

variables (H K L)

@[to_additive relindex_mul_relindex] lemma relindex_mul_relindex (hHK : H ≤ K) (hKL : K ≤ L) :
  H.relindex K * K.relindex L = H.relindex L :=
begin
  rw [←relindex_subgroup_of hKL],
  exact relindex_mul_index (λ x hx, hHK hx),
end

@[to_additive] lemma inf_relindex_right : (H ⊓ K).relindex K = H.relindex K :=
begin
  rw [←subgroup_of_map_subtype, relindex, relindex, subgroup_of, comap_map_eq_self_of_injective],
  exact subtype.coe_injective,
end

@[to_additive] lemma inf_relindex_left : (H ⊓ K).relindex H = K.relindex H :=
by rw [inf_comm, inf_relindex_right]

@[to_additive relindex_inf_mul_relindex]
lemma relindex_inf_mul_relindex : H.relindex (K ⊓ L) * K.relindex L = (H ⊓ K).relindex L :=
by rw [←inf_relindex_right H (K ⊓ L), ←inf_relindex_right K L, ←inf_relindex_right (H ⊓ K) L,
  inf_assoc, relindex_mul_relindex (H ⊓ (K ⊓ L)) (K ⊓ L) L inf_le_right inf_le_right]

@[to_additive]
lemma inf_relindex_eq_relindex_sup [K.normal] : (H ⊓ K).relindex H = K.relindex (H ⊔ K) :=
cardinal.to_nat_congr (quotient_group.quotient_inf_equiv_prod_normal_quotient H K).to_equiv

@[to_additive] lemma relindex_eq_relindex_sup [K.normal] : K.relindex H = K.relindex (H ⊔ K) :=
by rw [←inf_relindex_left, inf_relindex_eq_relindex_sup]

@[to_additive] lemma relindex_dvd_index_of_normal [H.normal] : H.relindex K ∣ H.index :=
(relindex_eq_relindex_sup K H).symm ▸ relindex_dvd_index_of_le le_sup_right

variables {H K}

@[to_additive] lemma relindex_dvd_of_le_left (hHK : H ≤ K) : K.relindex L ∣ H.relindex L :=
begin
  apply dvd_of_mul_left_eq ((H ⊓ L).relindex (K ⊓ L)),
  rw [←inf_relindex_right H L, ←inf_relindex_right K L],
  exact relindex_mul_relindex (H ⊓ L) (K ⊓ L) L (inf_le_inf_right L hHK) inf_le_right,
end

variables (H K)

@[simp, to_additive] lemma index_top : (⊤ : subgroup G).index = 1 :=
cardinal.to_nat_eq_one_iff_unique.mpr ⟨quotient_group.subsingleton_quotient_top, ⟨1⟩⟩

@[simp, to_additive] lemma index_bot : (⊥ : subgroup G).index = nat.card G :=
cardinal.to_nat_congr (quotient_group.quotient_bot.to_equiv)

@[to_additive] lemma index_bot_eq_card [fintype G] : (⊥ : subgroup G).index = fintype.card G :=
index_bot.trans nat.card_eq_fintype_card

@[simp, to_additive] lemma relindex_top_left : (⊤ : subgroup G).relindex H = 1 :=
index_top

@[simp, to_additive] lemma relindex_top_right : H.relindex ⊤ = H.index :=
by rw [←relindex_mul_index (show H ≤ ⊤, from le_top), index_top, mul_one]

@[simp, to_additive] lemma relindex_bot_left : (⊥ : subgroup G).relindex H = nat.card H :=
by rw [relindex, bot_subgroup_of, index_bot]

@[to_additive] lemma relindex_bot_left_eq_card [fintype H] :
  (⊥ : subgroup G).relindex H = fintype.card H :=
H.relindex_bot_left.trans nat.card_eq_fintype_card

@[simp, to_additive] lemma relindex_bot_right : H.relindex ⊥ = 1 :=
by rw [relindex, subgroup_of_bot_eq_top, index_top]

@[simp, to_additive] lemma relindex_self : H.relindex H = 1 :=
by rw [relindex, subgroup_of_self, index_top]

@[simp, to_additive card_mul_index]
lemma card_mul_index : nat.card H * H.index = nat.card G :=
by { rw [←relindex_bot_left, ←index_bot], exact relindex_mul_index bot_le }

@[to_additive] lemma nat_card_dvd_of_injective {G H : Type*} [group G] [group H] (f : G →* H)
  (hf : function.injective f) : nat.card G ∣ nat.card H :=
begin
  rw nat.card_congr (monoid_hom.of_injective hf).to_equiv,
  exact dvd.intro f.range.index f.range.card_mul_index,
end

@[to_additive] lemma nat_card_dvd_of_surjective {G H : Type*} [group G] [group H] (f : G →* H)
  (hf : function.surjective f) : nat.card H ∣ nat.card G :=
begin
  rw ← nat.card_congr (quotient_group.quotient_ker_equiv_of_surjective f hf).to_equiv,
  exact dvd.intro_left (nat.card f.ker) f.ker.card_mul_index,
end

@[to_additive] lemma card_dvd_of_surjective {G H : Type*} [group G] [group H] [fintype G]
  [fintype H] (f : G →* H) (hf : function.surjective f) : fintype.card H ∣ fintype.card G :=
by simp only [←nat.card_eq_fintype_card, nat_card_dvd_of_surjective f hf]

@[to_additive] lemma index_map {G' : Type*} [group G'] (f : G →* G') :
  (H.map f).index = (H ⊔ f.ker).index * f.range.index :=
by rw [←comap_map_eq, index_comap, relindex_mul_index (H.map_le_range f)]

@[to_additive] lemma index_map_dvd {G' : Type*} [group G'] {f : G →* G'}
  (hf : function.surjective f) : (H.map f).index ∣ H.index :=
begin
  rw [index_map, f.range_top_of_surjective hf, index_top, mul_one],
  exact index_dvd_of_le le_sup_left,
end

@[to_additive] lemma dvd_index_map {G' : Type*} [group G'] {f : G →* G'}
  (hf : f.ker ≤ H) : H.index ∣ (H.map f).index :=
begin
  rw [index_map, sup_of_le_left hf],
  apply dvd_mul_right,
end

@[to_additive] lemma index_map_eq {G' : Type*} [group G'] {f : G →* G'}
  (hf1 : function.surjective f) (hf2 : f.ker ≤ H) : (H.map f).index = H.index :=
nat.dvd_antisymm (H.index_map_dvd hf1) (H.dvd_index_map hf2)

@[to_additive] lemma index_eq_card [fintype (G ⧸ H)] :
  H.index = fintype.card (G ⧸ H) :=
nat.card_eq_fintype_card

@[to_additive index_mul_card] lemma index_mul_card [fintype G] [hH : fintype H] :
  H.index * fintype.card H = fintype.card G :=
by rw [←relindex_bot_left_eq_card, ←index_bot_eq_card, mul_comm]; exact relindex_mul_index bot_le

@[to_additive] lemma index_dvd_card [fintype G] : H.index ∣ fintype.card G :=
begin
  classical,
  exact ⟨fintype.card H, H.index_mul_card.symm⟩,
end

variables {H K L}

@[to_additive]
lemma relindex_eq_zero_of_le_left (hHK : H ≤ K) (hKL : K.relindex L = 0) : H.relindex L = 0 :=
eq_zero_of_zero_dvd (hKL ▸ (relindex_dvd_of_le_left L hHK))

@[to_additive]
lemma relindex_eq_zero_of_le_right (hKL : K ≤ L) (hHK : H.relindex K = 0) : H.relindex L = 0 :=
finite.card_eq_zero_of_embedding (quotient_subgroup_of_embedding_of_le H hKL) hHK

@[to_additive] lemma relindex_le_of_le_left (hHK : H ≤ K) (hHL : H.relindex L ≠ 0) :
  K.relindex L ≤ H.relindex L :=
nat.le_of_dvd (nat.pos_of_ne_zero hHL) (relindex_dvd_of_le_left L hHK)

@[to_additive] lemma relindex_le_of_le_right (hKL : K ≤ L) (hHL : H.relindex L ≠ 0) :
  H.relindex K ≤ H.relindex L :=
finite.card_le_of_embedding' (quotient_subgroup_of_embedding_of_le H hKL) (λ h, (hHL h).elim)

@[to_additive] lemma relindex_ne_zero_trans (hHK : H.relindex K ≠ 0) (hKL : K.relindex L ≠ 0) :
  H.relindex L ≠ 0 :=
λ h, mul_ne_zero (mt (relindex_eq_zero_of_le_right (show K ⊓ L ≤ K, from inf_le_left)) hHK) hKL
  ((relindex_inf_mul_relindex H K L).trans (relindex_eq_zero_of_le_left inf_le_left h))

@[to_additive] lemma relindex_inf_ne_zero (hH : H.relindex L ≠ 0) (hK : K.relindex L ≠ 0) :
  (H ⊓ K).relindex L ≠ 0 :=
begin
  replace hH : H.relindex (K ⊓ L) ≠ 0 := mt (relindex_eq_zero_of_le_right inf_le_right) hH,
  rw ← inf_relindex_right at hH hK ⊢,
  rw inf_assoc,
  exact relindex_ne_zero_trans hH hK,
end

@[to_additive] lemma index_inf_ne_zero (hH : H.index ≠ 0) (hK : K.index ≠ 0) : (H ⊓ K).index ≠ 0 :=
begin
  rw ← relindex_top_right at hH hK ⊢,
  exact relindex_inf_ne_zero hH hK,
end

@[to_additive] lemma relindex_inf_le : (H ⊓ K).relindex L ≤ H.relindex L * K.relindex L :=
begin
  by_cases h : H.relindex L = 0,
  { exact (le_of_eq (relindex_eq_zero_of_le_left (by exact inf_le_left) h)).trans (zero_le _) },
  rw [←inf_relindex_right, inf_assoc, ←relindex_mul_relindex _ _ L inf_le_right inf_le_right,
      inf_relindex_right, inf_relindex_right],
  exact mul_le_mul_right' (relindex_le_of_le_right inf_le_right h) (K.relindex L),
end

@[to_additive] lemma index_inf_le : (H ⊓ K).index ≤ H.index * K.index :=
by simp_rw [←relindex_top_right, relindex_inf_le]

@[to_additive] lemma relindex_infi_ne_zero {ι : Type*} [hι : finite ι] {f : ι → subgroup G}
  (hf : ∀ i, (f i).relindex L ≠ 0) : (⨅ i, f i).relindex L ≠ 0 :=
begin
  haveI := fintype.of_finite ι,
  exact finset.prod_ne_zero_iff.mpr (λ i hi, hf i) ∘ nat.card_pi.symm.trans ∘
    finite.card_eq_zero_of_embedding (quotient_infi_embedding f L),
end

@[to_additive] lemma relindex_infi_le {ι : Type*} [fintype ι] (f : ι → subgroup G) :
  (⨅ i, f i).relindex L ≤ ∏ i, (f i).relindex L :=
le_of_le_of_eq (finite.card_le_of_embedding' (quotient_infi_embedding f L)
  (λ h, let ⟨i, hi, h⟩ := finset.prod_eq_zero_iff.mp (nat.card_pi.symm.trans h) in
    relindex_eq_zero_of_le_left (infi_le f i) h)) nat.card_pi

@[to_additive] lemma index_infi_ne_zero {ι : Type*} [finite ι] {f : ι → subgroup G}
  (hf : ∀ i, (f i).index ≠ 0) : (⨅ i, f i).index ≠ 0 :=
begin
  simp_rw ← relindex_top_right at hf ⊢,
  exact relindex_infi_ne_zero hf,
end

@[to_additive] lemma index_infi_le {ι : Type*} [fintype ι] (f : ι → subgroup G) :
  (⨅ i, f i).index ≤ ∏ i, (f i).index :=
by simp_rw [←relindex_top_right, relindex_infi_le]

@[simp, to_additive index_eq_one] lemma index_eq_one : H.index = 1 ↔ H = ⊤ :=
⟨λ h, quotient_group.subgroup_eq_top_of_subsingleton H (cardinal.to_nat_eq_one_iff_unique.mp h).1,
  λ h, (congr_arg index h).trans index_top⟩

@[to_additive] lemma index_ne_zero_of_finite [hH : finite (G ⧸ H)] : H.index ≠ 0 :=
by { casesI nonempty_fintype (G ⧸ H), rw index_eq_card, exact fintype.card_ne_zero }

/-- Finite index implies finite quotient. -/
@[to_additive "Finite index implies finite quotient."]
noncomputable def fintype_of_index_ne_zero (hH : H.index ≠ 0) : fintype (G ⧸ H) :=
(cardinal.lt_aleph_0_iff_fintype.mp (lt_of_not_ge (mt cardinal.to_nat_apply_of_aleph_0_le hH))).some

@[to_additive one_lt_index_of_ne_top]
lemma one_lt_index_of_ne_top [finite (G ⧸ H)] (hH : H ≠ ⊤) : 1 < H.index :=
nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨index_ne_zero_of_finite, mt index_eq_one.mp hH⟩

end subgroup
