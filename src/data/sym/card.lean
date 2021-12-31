/-
Copyright (c) 2021 Yaël Dillies, Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Bhavik Mehta
-/
import algebra.big_operators.basic
import data.sym.sym2

/-!
# Stars and bars

In this file, we prove stars and bars.

## Informal statement

If we have `n` objects to put in `n` boxes, we can do so in exactly `(n + n - 1).choose n` ways.

## Formal statement

We can identify the `n` boxes with the elements of a fintype `α` of card `n`. Then placing `n`
elements in those boxes corresponds to choosing how many of each element of `α` appear in a multiset
of card `n`. `sym α n` being the subtype of `multiset α` of multisets of card `n`, writing stars
and bars using types gives
```lean
lemma stars_and_bars {α : Type*} [fintype α] (n : ℕ) :
  card (sym α n) = (card α + n - 1).choose n := sorry
```

## Tags

stars and bars
-/

open finset fintype function option sum

variables {α β : Type*}

@[simp] lemma option.coe_get {o : option α} (h : o.is_some) : ((option.get h : α) : option α) = o :=
option.some_get h

namespace multiset

@[simp] lemma map_le_map_iff {f : α ↪ β} {s t : multiset α} : s.map f ≤ t.map f ↔ s ≤ t :=
⟨λ h, begin
  sorry
end, map_le_map⟩

/-- Associate to an embedding `f` from `α` to `β` the order embedding that maps a multiset to its
image under `f`. -/
def map_embedding (f : α ↪ β) : multiset α ↪o multiset β :=
order_embedding.of_map_le_iff (map f) (λ _ _, map_le_map_iff)

end multiset

namespace finset

lemma map_injective (f : α ↪ β) : injective (map f) := (map_embedding f).injective

end finset

namespace sym
section attach
variables {n : ℕ}

def attach (s : sym α n) : sym {a // a ∈ s} n := ⟨s.1.attach, by rw [multiset.card_attach, s.2]⟩

@[simp] lemma coe_attach (s : sym α n) : (s.attach : multiset {a // a ∈ s}) = multiset.attach s :=
rfl

@[simp] lemma coe_map (s : sym α n) (f : α → β) : (s.map f : multiset β) = multiset.map f s := rfl

lemma attach_map_val (s : sym α n) : s.attach.map (embedding.subtype _) = s :=
coe_injective $ multiset.attach_map_val _

lemma coe_erase [decidable_eq α] {s : sym α n.succ} {a : α} (h : a ∈ s) :
  (s.erase a h : multiset α) = multiset.erase s a :=
rfl

lemma coe_cons [decidable_eq α] (s : sym α n) (a : α) : (a :: s : multiset α) = a ::ₘ s := rfl

@[simp] lemma cons_erase [decidable_eq α] {s : sym α n.succ} {a : α} (h : a ∈ s) :
  a :: s.erase a h = s :=
coe_injective $ multiset.cons_erase h

@[simp] lemma erase_cons_head [decidable_eq α] (s : sym α n) (a : α) (h : a ∈ a :: s) :
  (a :: s).erase a h = s :=
coe_injective $ multiset.erase_cons_head a s.1

lemma map_injective {f : α → β} (hf : injective f) (n : ℕ) :
  injective (map f : sym α n → sym β n) :=
λ s t h, coe_injective $ multiset.map_injective hf $ coe_inj.2 h

end attach

variables (α) [decidable_eq α] (n : ℕ)

/-- The `encode` function produces a `sym α n.succ` if the input doesn't contain `none` by casting
`option α` to `α`. Otherwise, the function removes an occurrence of `none` from the input and
produces a `sym (option α) n`. -/
def encode (s : sym (option α) n.succ) : sym α n.succ ⊕ sym (option α) n :=
if h : none ∈ s then inr (s.erase none h)
else inl $ s.attach.map $ λ o, get $ ne_none_iff_is_some.1 $ ne_of_mem_of_not_mem o.2 h

/-- From the output of `encode`, the `decode` function reconstructs the original input. If the
output contains `n + 1` elements, the original input can be reconstructed by casting `α` back
to `option α`. Otherwise, an instance of `none` has been removed and the input can be
reconstructed by adding it back. -/
def decode : sym α n.succ ⊕ sym (option α) n → sym (option α) n.succ
| (inl s) := s.map embedding.coe_option
| (inr s) := none :: s

variables {α n}

@[simp] lemma decode_inl (s : sym α n.succ) : decode α n (inl s) = s.map embedding.coe_option := rfl
@[simp] lemma decode_inr (s : sym (option α) n) : decode α n (inr s) = none :: s := rfl

variables (α n)

/-- As `encode` and `decode` are inverses of each other, `sym (option α) n.succ` is equivalent
to `sym α n.succ ⊕ sym (option α) n`. -/
def option_succ_equiv : sym (option α) n.succ ≃ sym α n.succ ⊕ sym (option α) n :=
{ to_fun := encode α n,
  inv_fun := decode α n,
  left_inv := λ s, begin
    unfold encode,
    split_ifs,
    { exact cons_erase _ },
    simp only [decode, sym.map_map, subtype.mk.inj_eq, function.comp],
    convert s.attach_map_val,
    ext o a,
    simp_rw [embedding.coe_option_apply, option.coe_get, embedding.coe_subtype, option.mem_def,
      subtype.val_eq_coe],
  end,
  right_inv := begin
    rintro (s | s),
    { unfold encode,
      split_ifs,
      { obtain ⟨a, _, ha⟩ := multiset.mem_map.mp h,
        exact some_ne_none _ ha },
      { refine map_injective (option.some_injective _) _ _,
        convert eq.trans _ (decode α n (inl s)).attach_map_val,
        simp } },
    { exact (dif_pos $ mem_cons_self _ _).trans (congr_arg _ $ erase_cons_head s _ _) }
  end }

/-- Define the multichoose number using `fintype.card`. -/
def multichoose1 (α : Type*) [decidable_eq α] [fintype α] (k : ℕ) := fintype.card (sym α k)

/-- Define the multichoose number using `nat.choose`. -/
def multichoose2 (n k : ℕ) := (n + k - 1).choose k

lemma multichoose1_rec (α : Type*) [decidable_eq α] [fintype α] (n : ℕ) :
  multichoose1 (option α) n.succ = multichoose1 α n.succ + multichoose1 (option α) n :=
by simpa only [multichoose1, fintype.card_sum.symm] using fintype.card_congr (option_succ_equiv α n)

lemma multichoose2_rec (n k : ℕ) :
  multichoose2 n.succ k.succ = multichoose2 n k.succ + multichoose2 n.succ k :=
by simp [multichoose2, nat.choose_succ_succ, nat.add_comm, nat.add_succ]

lemma multichoose1_eq_multichoose2 (α : Type*) [decidable_eq α] [fintype α] (n : ℕ) :
  multichoose1 α n = multichoose2 (fintype.card α) n :=
begin
  sorry
end

/-- The *stars and bars* lemma: the cardinality of `sym α n` is equal to
`(card α + n - 1) choose n`. -/
lemma stars_and_bars {α : Type*} [decidable_eq α] [fintype α] (n : ℕ) :
  fintype.card (sym α n) = (fintype.card α + n - 1).choose n :=
begin
  have start := multichoose1_eq_multichoose2 α n,
  simp only [multichoose1, multichoose2] at start,
  rw start.symm,
end

end sym

namespace sym2
variables [decidable_eq α]

/-- The `diag` of `s : finset α` is sent on a finset of `sym2 α` of card `s.card`. -/
lemma card_image_diag (s : finset α) :
  (s.diag.image quotient.mk).card = s.card :=
begin
  rw [card_image_of_inj_on, diag_card],
  rintro ⟨x₀, x₁⟩ hx _ _ h,
  cases quotient.eq.1 h,
  { refl },
  { simp only [mem_coe, mem_diag] at hx,
    rw hx.2 }
end

lemma two_mul_card_image_off_diag (s : finset α) :
  2 * (s.off_diag.image quotient.mk).card = s.off_diag.card :=
begin
  rw [card_eq_sum_card_fiberwise
    (λ x, mem_image_of_mem _ : ∀ x ∈ s.off_diag, quotient.mk x ∈ s.off_diag.image quotient.mk),
    sum_const_nat (quotient.ind _), mul_comm],
  rintro ⟨x, y⟩ hxy,
  simp_rw [mem_image, exists_prop, mem_off_diag, quotient.eq] at hxy,
  obtain ⟨a, ⟨ha₁, ha₂, ha⟩, h⟩ := hxy,
  obtain ⟨hx, hy, hxy⟩ : x ∈ s ∧ y ∈ s ∧ x ≠ y,
  { cases h; have := ha.symm; exact ⟨‹_›, ‹_›, ‹_›⟩ },
  have hxy' : y ≠ x := hxy.symm,
  have : s.off_diag.filter (λ z, ⟦z⟧ = ⟦(x, y)⟧) = ({(x, y), (y, x)} : finset _),
  { ext ⟨x₁, y₁⟩,
    rw [mem_filter, mem_insert, mem_singleton, sym2.eq_iff, prod.mk.inj_iff, prod.mk.inj_iff,
      and_iff_right_iff_imp],
    rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩); rw mem_off_diag; exact ⟨‹_›, ‹_›, ‹_›⟩ }, -- hxy' is used here
  rw [this, card_insert_of_not_mem, card_singleton],
  simp only [not_and, prod.mk.inj_iff, mem_singleton],
  exact λ _, hxy',
end

/-- The `off_diag` of `s : finset α` is sent on a finset of `sym2 α` of card `s.off_diag.card / 2`.
This is because every element `⟦(x, y)⟧` of `sym2 α` not on the diagonal comes from exactly two
pairs: `(x, y)` and `(y, x)`. -/
lemma card_image_off_diag (s : finset α) :
  (s.off_diag.image quotient.mk).card = s.card.choose 2 :=
by rw [nat.choose_two_right, mul_tsub, mul_one, ←off_diag_card,
  nat.div_eq_of_eq_mul_right zero_lt_two (two_mul_card_image_off_diag s).symm]

lemma card_subtype_diag [fintype α] :
  card {a : sym2 α // a.is_diag} = card α :=
begin
  convert card_image_diag (univ : finset α),
  rw [fintype.card_of_subtype, ←filter_image_quotient_mk_is_diag],
  rintro x,
  rw [mem_filter, univ_product_univ, mem_image],
  obtain ⟨a, ha⟩ := quotient.exists_rep x,
  exact and_iff_right ⟨a, mem_univ _, ha⟩,
end

lemma card_subtype_not_diag [fintype α] :
  card {a : sym2 α // ¬a.is_diag} = (card α).choose 2 :=
begin
  convert card_image_off_diag (univ : finset α),
  rw [fintype.card_of_subtype, ←filter_image_quotient_mk_not_is_diag],
  rintro x,
  rw [mem_filter, univ_product_univ, mem_image],
  obtain ⟨a, ha⟩ := quotient.exists_rep x,
  exact and_iff_right ⟨a, mem_univ _, ha⟩,
end

protected lemma card [fintype α] :
  card (sym2 α) = card α * (card α + 1) / 2 :=
by rw [←fintype.card_congr (@equiv.sum_compl _ is_diag (sym2.is_diag.decidable_pred α)),
  fintype.card_sum, card_subtype_diag, card_subtype_not_diag, nat.choose_two_right, add_comm,
  ←nat.triangle_succ, nat.succ_sub_one, mul_comm]

end sym2
