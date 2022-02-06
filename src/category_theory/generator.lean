/-
Copyright (c) 2022 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel
-/
import category_theory.balanced
import category_theory.limits.opposites
import data.set.opposite

/-!
# Separating and detecting sets

There are several non-equivalent notions of a generator of a category. Here, we consider two of
them:

* We say that `𝒢` is a separating set if the functors `C(G, -)` for `G ∈ 𝒢` are collectively
    faithful, i.e., if `h ≫ f = h ≫ g` for all `h` with domain in `𝒢` implies `f = g`.
* We say that `𝒢` is a detecting set if the functors `C(G, -)` collectively reflect isomorphisms,
    i.e., if any `h` with domain in `𝒢` uniquely factors through `f`, then `f` is an isomorphism.

There are, of course, also the dual notions of coseparating and codetecting sets.

## Main results

We
* define separating, coseparating, detecting and codetecting sets;
* show that separating and coseparating are dual notions;
* show that detecting and codetecting are dual notions;
* show that if `C` has equalizers, then detecting implies separating;
* show that if `C` has coequalizers, then codetecting implies separating;
* show that if `C` is balanced, then separating implies detecting and coseparating implies
  codetecting;
* show that `∅` is separating if and only if `∅` is coseparating if and only if `C` is thin;
* show that `∅` is detecting if and only if `∅` is codetecting if and only if `C` is a groupoid;
* define separators, coseparators, detectors and codetectors as the singleton counterparts to the
  definitions for sets above and restate the above results in this situation;
* show that `G` is a separator if and only if `coyoneda.obj (op G)` is faithful (and the dual);
* show that `G` is a detector if and only if `coyoneda.obj (op G)` reflects isomorphisms (and the
  dual).

## Future work

* We currently don't have any examples yet.
* If `C` is abelian, then there are interesting things to be said about objects `G` that are both
  projective and a separator.
* We will want typeclasses `has_separator C` and similar.
* To state the Special Adjoint Functor Theorem, we will need to be able to talk about *small*
  separating sets.

-/

universes v u

open category_theory.limits opposite

namespace category_theory
variables {C : Type u} [category.{v} C]

/-- We say that `𝒢` is a separating set if the functors `C(G, -)` for `G ∈ 𝒢` are collectively
    faithful, i.e., if `h ≫ f = h ≫ g` for all `h` with domain in `𝒢` implies `f = g`. -/
def separating (𝒢 : set C) : Prop :=
∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ (G ∈ 𝒢) (h : G ⟶ X), h ≫ f = h ≫ g) → f = g

/-- We say that `𝒢` is a coseparating set if the functors `C(-, G)` for `G ∈ 𝒢` are collectively
    faithful, i.e., if `f ≫ h = g ≫ h` for all `h` with codomain in `𝒢` implies `f = g`. -/
def coseparating (𝒢 : set C) : Prop :=
∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ (G ∈ 𝒢) (h : Y ⟶ G), f ≫ h = g ≫ h) → f = g

/-- We say that `𝒢` is a detecting set if the functors `C(G, -)` collectively reflect isomorphisms,
    i.e., if any `h` with domain in `𝒢` uniquely factors through `f`, then `f` is an isomorphism. -/
def detecting (𝒢 : set C) : Prop :=
∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ (G ∈ 𝒢) (h : G ⟶ Y), ∃! (h' : G ⟶ X), h' ≫ f = h) → is_iso f

/-- We say that `𝒢` is a codetecting set if the functors `C(-, G)` collectively reflect
    isomorphisms, i.e., if any `h` with codomain in `G` uniquely factors through `f`, then `f` is
    an isomorphism. -/
def codetecting (𝒢 : set C) : Prop :=
∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ (G ∈ 𝒢) (h : X ⟶ G), ∃! (h' : Y ⟶ G), f ≫ h' = h) → is_iso f

section dual

lemma separating_op_iff_coseparating {𝒢 : set C} : separating 𝒢.op ↔ coseparating 𝒢 :=
begin
  refine ⟨λ h𝒢 X Y f g hfg, _, λ h𝒢 X Y f g hfg, _⟩,
  { refine quiver.hom.op_inj (h𝒢 _ _ (λ G hG h, quiver.hom.unop_inj _)),
    simpa only [unop_comp, quiver.hom.unop_op] using hfg _ (set.mem_op.1 hG) _ },
  { refine quiver.hom.unop_inj (h𝒢 _ _ (λ G hG h, quiver.hom.op_inj _)),
    simpa only [op_comp, quiver.hom.op_unop] using hfg _ (set.op_mem_op.2 hG) _ }
end

lemma coseparating_op_iff_separating (𝒢 : set C) : coseparating 𝒢.op ↔ separating 𝒢 :=
begin
  refine ⟨λ h𝒢 X Y f g hfg, _, λ h𝒢 X Y f g hfg, _⟩,
  { refine quiver.hom.op_inj (h𝒢 _ _ (λ G hG h, quiver.hom.unop_inj _)),
    simpa only [unop_comp, quiver.hom.unop_op] using hfg _ (set.mem_op.1 hG) _ },
  { refine quiver.hom.unop_inj (h𝒢 _ _ (λ G hG h, quiver.hom.op_inj _)),
    simpa only [op_comp, quiver.hom.op_unop] using hfg _ (set.op_mem_op.2 hG) _ }
end

lemma coseparating_unop_iff_separating (𝒢 : set Cᵒᵖ) : coseparating 𝒢.unop ↔ separating 𝒢 :=
by rw [← separating_op_iff_coseparating, set.unop_op]

lemma separating_unop_iff_coseparating (𝒢 : set Cᵒᵖ) : separating 𝒢.unop ↔ coseparating 𝒢 :=
by rw [← coseparating_op_iff_separating, set.unop_op]

lemma detecting_op_iff_codetecting {𝒢 : set C} : detecting 𝒢.op ↔ codetecting 𝒢 :=
begin
  refine ⟨λ h𝒢 X Y f hf, _, λ h𝒢 X Y f hf, _⟩,
  { refine (is_iso_op_iff _).1 (h𝒢 _ (λ G hG h, _)),
    obtain ⟨t, ht, ht'⟩ := hf (unop G) (set.mem_op.1 hG) h.unop,
    exact ⟨t.op, quiver.hom.unop_inj ht, λ y hy,
      quiver.hom.unop_inj (ht' _ (quiver.hom.op_inj hy))⟩ },
  { refine (is_iso_unop_iff _).1 (h𝒢 _ (λ G hG h, _)),
    obtain ⟨t, ht, ht'⟩ := hf (op G) (set.op_mem_op.2 hG) h.op,
    refine ⟨t.unop, quiver.hom.op_inj ht, λ y hy, quiver.hom.op_inj (ht' _ _)⟩,
    exact quiver.hom.unop_inj (by simpa only using hy) }
end

lemma codetecting_op_iff_detecting {𝒢 : set C} : codetecting 𝒢.op ↔ detecting 𝒢 :=
begin
  refine ⟨λ h𝒢 X Y f hf, _, λ h𝒢 X Y f hf, _⟩,
  { refine (is_iso_op_iff _).1 (h𝒢 _ (λ G hG h, _)),
    obtain ⟨t, ht, ht'⟩ := hf (unop G) (set.mem_op.1 hG) h.unop,
    exact ⟨t.op, quiver.hom.unop_inj ht, λ y hy,
      quiver.hom.unop_inj (ht' _ (quiver.hom.op_inj hy))⟩ },
  { refine (is_iso_unop_iff _).1 (h𝒢 _ (λ G hG h, _)),
    obtain ⟨t, ht, ht'⟩ := hf (op G) (set.op_mem_op.2 hG) h.op,
    refine ⟨t.unop, quiver.hom.op_inj ht, λ y hy, quiver.hom.op_inj (ht' _ _)⟩,
    exact quiver.hom.unop_inj (by simpa only using hy) }
end

lemma detecting_unop_iff_codetecting {𝒢 : set Cᵒᵖ} : detecting 𝒢.unop ↔ codetecting 𝒢 :=
by rw [← codetecting_op_iff_detecting, set.unop_op]

lemma codetecting_unop_iff_detecting {𝒢 : set Cᵒᵖ} : codetecting 𝒢.unop ↔ detecting 𝒢 :=
by rw [← detecting_op_iff_codetecting, set.unop_op]

end dual

lemma detecting.separating [has_equalizers C] {𝒢 : set C} (h𝒢 : detecting 𝒢) : separating 𝒢 :=
λ X Y f g hfg,
  have is_iso (equalizer.ι f g), from h𝒢 _ (λ G hG h, equalizer.exists_unique _ (hfg _ hG _)),
  by exactI eq_of_epi_equalizer

section
local attribute [instance] has_equalizers_opposite

lemma codetecting.coseparating [has_coequalizers C] {𝒢 : set C} : codetecting 𝒢 → coseparating 𝒢 :=
by simpa only [← separating_op_iff_coseparating, ← detecting_op_iff_codetecting]
  using detecting.separating

end

lemma separating.detecting [balanced C] {𝒢 : set C} (h𝒢 : separating 𝒢) : detecting 𝒢 :=
begin
  intros X Y f hf,
  refine (is_iso_iff_mono_and_epi _).2 ⟨⟨λ Z g h hgh, h𝒢 _ _ (λ G hG i, _)⟩, ⟨λ Z g h hgh, _⟩⟩,
  { obtain ⟨t, -, ht⟩ := hf G hG (i ≫ g ≫ f),
    rw [ht (i ≫ g) (category.assoc _ _ _), ht (i ≫ h) (hgh.symm ▸ category.assoc _ _ _)] },
  { refine h𝒢 _ _ (λ G hG i, _),
    obtain ⟨t, ht, -⟩ := hf G hG i,
    rw [← ht, category.assoc, hgh, category.assoc] }
end

section
local attribute [instance] balanced_opposite

lemma coseparating.codetecting [balanced C] {𝒢 : set C} : coseparating 𝒢 → codetecting 𝒢 :=
by simpa only [← detecting_op_iff_codetecting, ← separating_op_iff_coseparating]
  using separating.detecting

end

lemma detecting_iff_separating [has_equalizers C] [balanced C] {𝒢 : set C} :
  detecting 𝒢 ↔ separating 𝒢 :=
⟨detecting.separating, separating.detecting⟩

lemma codetecting_iff_coseparating [has_coequalizers C] [balanced C] {𝒢 : set C} :
  codetecting 𝒢 ↔ coseparating 𝒢 :=
⟨codetecting.coseparating, coseparating.codetecting⟩

section mono

lemma separating.mono {𝒢 : set C} (h𝒢 : separating 𝒢) {ℋ : set C} (h𝒢ℋ : 𝒢 ⊆ ℋ) :
  separating ℋ :=
λ X Y f g hfg, h𝒢 _ _ $ λ G hG h, hfg _ (h𝒢ℋ hG) _

lemma coseparating.mono {𝒢 : set C} (h𝒢 : coseparating 𝒢) {ℋ : set C} (h𝒢ℋ : 𝒢 ⊆ ℋ) :
  coseparating ℋ :=
λ X Y f g hfg, h𝒢 _ _ $ λ G hG h, hfg _ (h𝒢ℋ hG) _

lemma detecting.mono {𝒢 : set C} (h𝒢 : detecting 𝒢) {ℋ : set C} (h𝒢ℋ : 𝒢 ⊆ ℋ) : detecting ℋ :=
λ X Y f hf, h𝒢 _ $ λ G hG h, hf _ (h𝒢ℋ hG) _

lemma codetecting.mono {𝒢 : set C} (h𝒢 : codetecting 𝒢) {ℋ : set C} (h𝒢ℋ : 𝒢 ⊆ ℋ) :
  codetecting ℋ :=
λ X Y f hf, h𝒢 _ $ λ G hG h, hf _ (h𝒢ℋ hG) _

end mono

section empty

lemma thin_of_separating_empty (h : separating (∅ : set C)) (X Y : C) : subsingleton (X ⟶ Y) :=
⟨λ f g, h _ _ $ λ G, false.elim⟩

lemma separating_empty_of_thin [∀ X Y : C, subsingleton (X ⟶ Y)] : separating (∅ : set C) :=
λ X Y f g hfg, subsingleton.elim _ _

lemma thin_of_coseparating_empty (h : coseparating (∅ : set C)) (X Y : C) : subsingleton (X ⟶ Y) :=
⟨λ f g, h _ _ $ λ G, false.elim⟩

lemma coseparating_empty_of_thin [∀ X Y : C, subsingleton (X ⟶ Y)] : coseparating (∅ : set C) :=
λ X Y f g hfg, subsingleton.elim _ _

lemma groupoid_of_detecting_empty (h : detecting (∅ : set C)) {X Y : C} (f : X ⟶ Y) : is_iso f :=
h _ $ λ G, false.elim

lemma detecting_empty_of_groupoid [∀ {X Y : C} (f : X ⟶ Y), is_iso f] : detecting (∅ : set C) :=
λ X Y f hf, infer_instance

lemma groupoid_of_codetecting_empty (h : codetecting (∅ : set C)) {X Y : C} (f : X ⟶ Y) :
  is_iso f :=
h _ $ λ G, false.elim

lemma codetecting_empty_of_groupoid [∀ {X Y : C} (f : X ⟶ Y), is_iso f] :
  codetecting (∅ : set C) :=
λ X Y f hf, infer_instance

end empty

/-- We say that `G` is a separator if the functor `C(G, -)` is faithful. -/
def separator (G : C) : Prop :=
separating ({G} : set C)

/-- We say that `G` is a coseparator if the functor `C(-, G)` is faithful. -/
def coseparator (G : C) : Prop :=
coseparating ({G} : set C)

/-- We say that `G` is a detector if the functor `C(G, -)` reflects isomorphisms. -/
def detector (G : C) : Prop :=
detecting ({G} : set C)

/-- We say that `G` is a codetector if the functor `C(-, G)` reflects isomorphisms. -/
def codetector (G : C) : Prop :=
codetecting ({G} : set C)

section dual

lemma separator_op_iff_coseparator (G : C) : separator (op G) ↔ coseparator G :=
by rw [separator, coseparator, ← separating_op_iff_coseparating, set.singleton_op]

lemma coseparator_op_iff_separator (G : C) : coseparator (op G) ↔ separator G :=
by rw [separator, coseparator, ← coseparating_op_iff_separating, set.singleton_op]

lemma coseparator_unop_iff_separator (G : Cᵒᵖ) : coseparator (unop G) ↔ separator G :=
by rw [separator, coseparator, ← coseparating_unop_iff_separating, set.singleton_unop]

lemma separator_unop_iff_coseparator (G : Cᵒᵖ) : separator (unop G) ↔ coseparator G :=
by rw [separator, coseparator, ← separating_unop_iff_coseparating, set.singleton_unop]

lemma detector_op_iff_codetector (G : C) : detector (op G) ↔ codetector G :=
by rw [detector, codetector, ← detecting_op_iff_codetecting, set.singleton_op]

lemma codetector_op_iff_detector (G : C) : codetector (op G) ↔ detector G :=
by rw [detector, codetector, ← codetecting_op_iff_detecting, set.singleton_op]

lemma codetector_unop_iff_detector (G : Cᵒᵖ) : codetector (unop G) ↔ detector G :=
by rw [detector, codetector, ← codetecting_unop_iff_detecting, set.singleton_unop]

lemma detector_unop_iff_codetector (G : Cᵒᵖ) : detector (unop G) ↔ codetector G :=
by rw [detector, codetector, ← detecting_unop_iff_codetecting, set.singleton_unop]

end dual

lemma detector.separator [has_equalizers C] {G : C} : detector G → separator G :=
detecting.separating

lemma codetector.coseparator [has_coequalizers C] {G : C} : codetector G → coseparator G :=
codetecting.coseparating

lemma separator.detector [balanced C] {G : C} : separator G → detector G :=
separating.detecting

lemma cospearator.codetector [balanced C] {G : C} : coseparator G → codetector G :=
coseparating.codetecting

lemma separator_def {G : C} :
  separator G ↔ ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ h : G ⟶ X, h ≫ f = h ≫ g) → f = g :=
⟨λ hG X Y f g hfg, hG _ _ $ λ H hH h, by { obtain rfl := set.mem_singleton_iff.1 hH, exact hfg h },
 λ hG X Y f g hfg, hG _ _ $ λ h, hfg _ (set.mem_singleton _) _⟩

lemma separator.def {G : C} :
  separator G → ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ h : G ⟶ X, h ≫ f = h ≫ g) → f = g :=
separator_def.1

lemma coseparator_def {G : C} :
  coseparator G ↔ ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ h : Y ⟶ G, f ≫ h = g ≫ h) → f = g :=
⟨λ hG X Y f g hfg, hG _ _ $ λ H hH h, by { obtain rfl := set.mem_singleton_iff.1 hH, exact hfg h },
 λ hG X Y f g hfg, hG _ _ $ λ h, hfg _ (set.mem_singleton _) _⟩

lemma coseparator.def {G : C} :
  coseparator G → ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), (∀ h : Y ⟶ G, f ≫ h = g ≫ h) → f = g :=
coseparator_def.1

lemma detector_def {G : C} :
  detector G ↔ ∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ h : G ⟶ Y, ∃! h', h' ≫ f = h) → is_iso f :=
⟨λ hG X Y f hf, hG _ $ λ H hH h, by { obtain rfl := set.mem_singleton_iff.1 hH, exact hf h },
 λ hG X Y f hf, hG _ $ λ h, hf _ (set.mem_singleton _) _⟩

lemma detector.def {G : C} :
  detector G → ∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ h : G ⟶ Y, ∃! h', h' ≫ f = h) → is_iso f :=
detector_def.1

lemma codetector_def {G : C} :
  codetector G ↔ ∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ h : X ⟶ G, ∃! h', f ≫ h' = h) → is_iso f :=
⟨λ hG X Y f hf, hG _ $ λ H hH h, by { obtain rfl := set.mem_singleton_iff.1 hH, exact hf h },
 λ hG X Y f hf, hG _ $ λ h, hf _ (set.mem_singleton _) _⟩

lemma codetector.def {G : C} :
  codetector G → ∀ ⦃X Y : C⦄ (f : X ⟶ Y), (∀ h : X ⟶ G, ∃! h', f ≫ h' = h) → is_iso f :=
codetector_def.1

lemma separator_iff_faithful_coyoneda_obj {G : C} : separator G ↔ faithful (coyoneda.obj (op G)) :=
⟨λ hG, ⟨λ X Y f g hfg, hG.def _ _ (congr_fun hfg)⟩,
 λ h, separator_def.2 $ λ X Y f g hfg, by exactI (coyoneda.obj (op G)).map_injective (funext hfg)⟩

lemma coseparator_iff_faithful_yoneda_obj {G : C} : coseparator G ↔ faithful (yoneda.obj G) :=
⟨λ hG, ⟨λ X Y f g hfg, quiver.hom.unop_inj (hG.def _ _ (congr_fun hfg))⟩,
 λ h, coseparator_def.2 $ λ X Y f g hfg, quiver.hom.op_inj $
  by exactI (yoneda.obj G).map_injective (funext hfg)⟩

lemma detector_iff_reflects_isomorphisms_coyoneda_obj {G : C} :
  detector G ↔ reflects_isomorphisms (coyoneda.obj (op G)) :=
begin
  refine ⟨λ hG, ⟨λ X Y f hf, hG.def _ (λ h, _)⟩, λ h, detector_def.2 (λ X Y f hf, _)⟩,
  { rw [is_iso_iff_bijective, function.bijective_iff_exists_unique] at hf,
    exact hf h },
  { suffices : is_iso ((coyoneda.obj (op G)).map f),
    { exactI @is_iso_of_reflects_iso _ _ _ _ _ _ _ (coyoneda.obj (op G)) _ h },
    rwa [is_iso_iff_bijective, function.bijective_iff_exists_unique] }
end

lemma codetector_iff_reflects_isomorphisms_yoneda_obj {G : C} :
  codetector G ↔ reflects_isomorphisms (yoneda.obj G) :=
begin
  refine ⟨λ hG, ⟨λ X Y f hf, _ ⟩, λ h, codetector_def.2 (λ X Y f hf, _)⟩,
  { refine (is_iso_unop_iff _).1 (hG.def _ _),
    rwa [is_iso_iff_bijective, function.bijective_iff_exists_unique] at hf },
  { rw ← is_iso_op_iff,
    suffices : is_iso ((yoneda.obj G).map f.op),
    { exactI @is_iso_of_reflects_iso _ _ _ _ _ _ _ (yoneda.obj G) _ h },
    rwa [is_iso_iff_bijective, function.bijective_iff_exists_unique] }
end

end category_theory
