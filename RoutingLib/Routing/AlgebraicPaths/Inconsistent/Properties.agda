open import Level using (_⊔_)
open import Data.Nat using (ℕ; suc; zero; _<_)
open import Data.Sum using (inj₁; inj₂)
open import Relation.Nullary using (¬_; yes; no)
open import Data.Product using (∃₂; _×_; _,_)
open import Data.Fin using (Fin)
open import Data.Fin.Properties using () renaming (_≟_ to _≟ᶠ_)
open import Data.Maybe using (just; nothing)
open import Relation.Nullary.Negation using (contradiction)
open import Relation.Binary using (Decidable; Rel; IsDecEquivalence; Transitive)
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; subst) renaming (refl to ≡-refl; sym to ≡-sym; trans to ≡-trans)
open import Algebra.FunctionProperties using (Op₂; Selective; Idempotent; Associative; Commutative; RightIdentity; RightZero)

open import RoutingLib.Routing.Definitions
open import RoutingLib.Data.Graph using (Graph; _∈_; _∈?_)
open import RoutingLib.Data.Graph.SimplePath renaming (_≈_ to _≈ₚ_)
open import RoutingLib.Data.Graph.SimplePath.Properties renaming (_≟_ to _≟ₚ_)
open import RoutingLib.Data.Graph.SimplePath.NonEmpty.Properties using (p≉i∷p)

module RoutingLib.Routing.AlgebraicPaths.Inconsistent.Properties
  {a b ℓ} (ra : RoutingAlgebra a b ℓ)
  (⊕-sel : Selective (RoutingAlgebra._≈_ ra) (RoutingAlgebra._⊕_ ra))
  {n : ℕ}
  (G : Graph (RoutingAlgebra.Step ra) n)
  where

  open RoutingAlgebra ra
  open import RoutingLib.Routing.AlgebraicPaths.Inconsistent ra ⊕-sel G
  open import RoutingLib.Algebra.Selectivity.Properties _≈_ _⊕_ ⊕-sel using () renaming (idem to ⊕-idem)
  open import RoutingLib.Algebra.Selectivity.NaturalOrders S _⊕_ ⊕-pres-≈ using (_≤ᵣ_; ≤ᵣ-trans; ≤ᵣ⇨≤ₗ; ≤ₗ⇨≤ᵣ)


  abstract

    -------------------
    -- ⊕ⁱ properties --
    -------------------

    ⊕ⁱ-sel : Selective _≈ⁱ_ _⊕ⁱ_
    ⊕ⁱ-sel inull          _          = inj₂ ≈ⁱ-refl
    ⊕ⁱ-sel (iroute _ _) inull        = inj₁ ≈ⁱ-refl
    ⊕ⁱ-sel (iroute x p) (iroute y q) with select x y
    ... | sel₁ _ _ = inj₁ ≈ⁱ-refl
    ... | sel₂ _ _ = inj₂ ≈ⁱ-refl
    ... | sel≈ _ _ with p ≤ₚ? q
    ...   | yes _ = inj₁ ≈ⁱ-refl
    ...   | no  _ = inj₂ ≈ⁱ-refl

    ⊕ⁱ-comm : Commutative _≈_ _⊕_ → Commutative _≈ⁱ_ _⊕ⁱ_
    ⊕ⁱ-comm _    inull        inull        = ≈ⁱ-refl
    ⊕ⁱ-comm _    inull        (iroute _ _) = ≈ⁱ-refl
    ⊕ⁱ-comm _    (iroute _ _) inull        = ≈ⁱ-refl
    ⊕ⁱ-comm comm (iroute x p) (iroute y q) with select x y | select y x
    ... | sel₁ x⊕y≈x _     | sel₁ _     y⊕x≉x = contradiction (trans (comm y x) x⊕y≈x) y⊕x≉x
    ... | sel₁ _     _     | sel₂ _     _     = ≈ⁱ-refl
    ... | sel₁ _     x⊕y≉y | sel≈ y⊕x≈y _     = contradiction (trans (comm x y) y⊕x≈y) x⊕y≉y
    ... | sel₂ _ _         | sel₁ _     _     = ≈ⁱ-refl
    ... | sel₂ x⊕y≉x _     | sel₂ _     y⊕x≈x = contradiction (trans (comm x y) y⊕x≈x) x⊕y≉x
    ... | sel₂ x⊕y≉x _     | sel≈ _     y⊕x≈x = contradiction (trans (comm x y) y⊕x≈x) x⊕y≉x
    ... | sel≈ x⊕y≈x _     | sel₁ _     y⊕x≉x = contradiction (trans (comm y x) x⊕y≈x) y⊕x≉x
    ... | sel≈ _     x⊕y≈y | sel₂ y⊕x≉y _     = contradiction (trans (comm y x) x⊕y≈y) y⊕x≉y
    ... | sel≈ x⊕y≈x x⊕y≈y | sel≈ _     _     with p ≤ₚ? q | q ≤ₚ? p
    ...   | yes p≤q | yes q≤p = irouteEq (trans (sym x⊕y≈x) x⊕y≈y) (≤ₚ-antisym p≤q q≤p)
    ...   | yes _   | no  _   = ≈ⁱ-refl
    ...   | no  _   | yes _   = ≈ⁱ-refl
    ...   | no  p≰q | no  q≰p with ≤ₚ-total p q
    ...     | inj₁ p≤q = contradiction p≤q p≰q
    ...     | inj₂ q≤p = contradiction q≤p q≰p


    ⊕ⁱ-assoc : Commutative _≈_ _⊕_ → Associative _≈_ _⊕_ → Associative _≈ⁱ_ _⊕ⁱ_
    ⊕ⁱ-assoc comm assoc inull        inull        inull        = ≈ⁱ-refl
    ⊕ⁱ-assoc comm assoc inull        inull        (iroute _ _) = ≈ⁱ-refl
    ⊕ⁱ-assoc comm assoc inull        (iroute _ _) inull        = ≈ⁱ-refl
    ⊕ⁱ-assoc comm assoc inull        (iroute _ _) (iroute _ _) = ≈ⁱ-refl
    ⊕ⁱ-assoc comm assoc (iroute _ _) inull        inull        = ≈ⁱ-refl
    ⊕ⁱ-assoc comm assoc (iroute _ _) inull        (iroute _ _) = ≈ⁱ-refl
    ⊕ⁱ-assoc comm assoc (iroute x p) (iroute y q) inull        with select x y
    ... | sel₁ _ _ = ≈ⁱ-refl
    ... | sel₂ _ _ = ≈ⁱ-refl
    ... | sel≈ _ _ with p ≤ₚ? q
    ...   | yes _ = ≈ⁱ-refl
    ...   | no  _ = ≈ⁱ-refl
    ⊕ⁱ-assoc comm assoc (iroute x p) (iroute y q) (iroute z r) = res

      where

      res : (iroute x p ⊕ⁱ iroute y q) ⊕ⁱ iroute z r ≈ⁱ iroute x p ⊕ⁱ (iroute y q ⊕ⁱ iroute z r)
      res with select x y | select y z
      res | sel₁ _   _   | sel₁ _   _   with select x y | select x z
      res | sel₁ _   _   | sel₁ _   _   | sel₁ _   _   | sel₁ _   _   = ≈ⁱ-refl
      res | sel₁ x≤y _   | sel₁ _   z≰y | sel₁ _   _   | sel₂ _   z≤x = contradiction (≤ᵣ-trans assoc z≤x (≤ₗ⇨≤ᵣ comm x≤y)) z≰y
      res | sel₁ x≤y _   | sel₁ _   z≰y | sel₁ _   _   | sel≈ _   z≤x = contradiction (≤ᵣ-trans assoc z≤x (≤ₗ⇨≤ᵣ comm x≤y)) z≰y
      res | sel₁ x≤y _   | sel₁ _   _   | sel₂ x≰y _   | _            = contradiction x≤y x≰y
      res | sel₁ _   y≰x | sel₁ _   _   | sel≈ _   y≤x | _            = contradiction y≤x y≰x
      res | sel₁ _   _   | sel₂ _   _   = ≈ⁱ-refl
      res | sel₁ _   _   | sel≈ _   _   with q ≤ₚ? r
      res | sel₁ _   _   | sel≈ _   _   | yes _        with select x y | select x z
      res | sel₁ _   _   | sel≈ _   _   | yes _        | sel₁ _   _   | sel₁ _   _   = ≈ⁱ-refl
      res | sel₁ x≤y _   | sel≈ y≤z _   | yes _        | sel₁ _   _   | sel₂ x≰z _   = contradiction (≤ᵣ⇨≤ₗ comm (≤ᵣ-trans assoc (≤ₗ⇨≤ᵣ comm x≤y) (≤ₗ⇨≤ᵣ comm y≤z))) x≰z
      res | sel₁ _   y≰x | sel≈ y≤z _   | yes _        | sel₁ _   _   | sel≈ _   z≤x = contradiction (≤ᵣ-trans assoc (≤ₗ⇨≤ᵣ comm y≤z) z≤x) y≰x
      res | sel₁ x≤y _   | sel≈ _   _   | yes _        | sel₂ x≰y _   | _            = contradiction x≤y x≰y
      res | sel₁ _   y≰x | sel≈ _   _   | yes _        | sel≈ _   y≤x | _            = contradiction y≤x y≰x
      res | sel₁ _   _   | sel≈ _   _   | no  _        = ≈ⁱ-refl
      res | sel₂ _   _   | sel₁ _   _   with select x y | select y z
      res | sel₂ _   y≤x | sel₁ _   _   | sel₁ _   y≰x | _            = contradiction y≤x y≰x
      res | sel₂ _   _   | sel₁ _   _   | sel₂ _   _   | sel₁ _   _   = ≈ⁱ-refl
      res | sel₂ x≰y _   | sel₁ _   _   | sel≈ x≤y _   | _            = contradiction x≤y x≰y
      res | sel₂ _   _   | sel₁ y≤z _   | _            | sel₂ y≰z _   = contradiction y≤z y≰z
      res | sel₂ _   _   | sel₁ _   z≰y | _            | sel≈ _   z≤y = contradiction z≤y z≰y
      res | sel₂ _   _   | sel₂ _   _   with select x z | select y z
      res | sel₂ _   _   | sel₂ _   z≤y | _            | sel₁ _   z≰y = contradiction z≤y z≰y
      res | sel₂ x≰y _   | sel₂ _   z≤y | sel₁ x≤z _   | sel₂ _   _   = contradiction (≤ᵣ⇨≤ₗ comm (≤ᵣ-trans assoc (≤ₗ⇨≤ᵣ comm x≤z) z≤y)) x≰y
      res | sel₂ _   _   | sel₂ _   _   | sel₂ _   _   | sel₂ _   _   = ≈ⁱ-refl
      res | sel₂ x≰y _   | sel₂ _   z≤y | sel≈ x≤z _   | sel₂ _   _   = contradiction (≤ᵣ⇨≤ₗ comm (≤ᵣ-trans assoc (≤ₗ⇨≤ᵣ comm x≤z) z≤y)) x≰y
      res | sel₂ _   _   | sel₂ y≰z _   | _            | sel≈ y≤z _   = contradiction y≤z y≰z
      res | sel₂ _   _   | sel≈ _   _   with q ≤ₚ? r
      res | sel₂ _   _   | sel≈ _   _   | yes _        with select x y | select y z
      res | sel₂ _   y≤x | sel≈ _   _   | yes _        | sel₁ _   y≰x | _            = contradiction y≤x y≰x
      res | sel₂ _   _   | sel≈ _   z≤y | yes _        | _            | sel₁ _   z≰y = contradiction z≤y z≰y
      res | sel₂ _   _   | sel≈ y≤z _   | yes _        | _            | sel₂ y≰z _   = contradiction y≤z y≰z
      res | sel₂ _   _   | sel≈ _   _   | yes _        | sel₂ _   _   | sel≈ _   _   with q ≤ₚ? r
      res | sel₂ _   _   | sel≈ _   _   | yes _        | sel₂ _   _   | sel≈ _   _   | yes _        = ≈ⁱ-refl
      res | sel₂ _   _   | sel≈ _   _   | yes q≤r      | sel₂ _   _   | sel≈ _   _   | no  q≰r      = contradiction q≤r q≰r
      res | sel₂ x≰y _   | sel≈ _   _   | yes _        | sel≈ x≤y _   | _            = contradiction x≤y x≰y
      res | sel₂ _   _   | sel≈ _   _   | no  _        with select x z | select y z
      res | sel₂ _   _   | sel≈ _   z≤y | no  _        | _            | sel₁ _   z≰y = contradiction z≤y z≰y
      res | sel₂ _   _   | sel≈ y≤z _   | no  _        | _            | sel₂ y≰z _   = contradiction y≤z y≰z
      res | sel₂ x≰y _   | sel≈ _   z≤y | no  _        | sel₁ x≤z _   | sel≈ _   _   = contradiction (≤ᵣ⇨≤ₗ comm (≤ᵣ-trans assoc (≤ₗ⇨≤ᵣ comm x≤z) z≤y)) x≰y
      res | sel₂ _   _   | sel≈ _   _   | no  _        | sel₂ _   _   | sel≈ _   _   with q ≤ₚ? r
      res | sel₂ _   _   | sel≈ _   _   | no  q≰r      | sel₂ _   _   | sel≈ _   _   | yes q≤r      = contradiction q≤r q≰r
      res | sel₂ _   _   | sel≈ _   _   | no  _        | sel₂ _   _   | sel≈ _   _   | no  _        = ≈ⁱ-refl
      res | sel₂ x≰y _   | sel≈ _   z≤y | no  _        | sel≈ x≤z _   | sel≈ _   _   = contradiction (≤ᵣ⇨≤ₗ comm (≤ᵣ-trans assoc (≤ₗ⇨≤ᵣ comm x≤z) z≤y)) x≰y
      res | sel≈ _   _   | sel₁ _   _   with p ≤ₚ? q
      res | sel≈ _   _   | sel₁ _   _   | yes _        with select x y | select x z
      res | sel≈ _   y≤x | sel₁ _   _   | yes _        | sel₁ _   y≰x | _            = contradiction y≤x y≰x
      res | sel≈ x≤y _   | sel₁ _   _   | yes _        | sel₂ x≰y _   | _            = contradiction x≤y x≰y
      res | sel≈ _   _   | sel₁ _   _   | yes _        | sel≈ _   _   | sel₁ _   _   with p ≤ₚ? q
      res | sel≈ _   _   | sel₁ _   _   | yes _        | sel≈ _   _   | sel₁ _   _   | yes _         = ≈ⁱ-refl
      res | sel≈ _   _   | sel₁ _   _   | yes p≤q      | sel≈ _   _   | sel₁ _   _   | no  p≰q       = contradiction p≤q p≰q
      res | sel≈ x≤y _   | sel₁ _   z≰y | yes _        | sel≈ _   _   | sel₂ _   z≤x = contradiction (≤ᵣ-trans assoc z≤x (≤ₗ⇨≤ᵣ comm x≤y)) z≰y
      res | sel≈ x≤y _   | sel₁ _   z≰y | yes _        | sel≈ _   _   | sel≈ _   z≤x = contradiction (≤ᵣ-trans assoc z≤x (≤ₗ⇨≤ᵣ comm x≤y)) z≰y
      res | sel≈ _   _   | sel₁ _   _   | no  _        with select x y | select y z
      res | sel≈ _   y≤x | sel₁ _   _   | no  _        | sel₁ _   y≰x | _            = contradiction y≤x y≰x
      res | sel≈ x≤y _   | sel₁ _   _   | no  _        | sel₂ x≰y _   | _            = contradiction x≤y x≰y
      res | sel≈ _   _   | sel₁ _   _   | no  _        | sel≈ _   _   | sel₁ _   _   with p ≤ₚ? q
      res | sel≈ _   _   | sel₁ _   _   | no  p≰q      | sel≈ _   _   | sel₁ _   _   | yes p≤q      = contradiction p≤q p≰q
      res | sel≈ _   _   | sel₁ _   _   | no  _        | sel≈ _   _   | sel₁ _   _   | no  _        = ≈ⁱ-refl
      res | sel≈ _   _   | sel₁ x≤y _   | no  _        | _            | sel₂ x≰y _   = contradiction x≤y x≰y
      res | sel≈ _   _   | sel₁ _   y≰x | no  _        | _            | sel≈ _   y≤x = contradiction y≤x y≰x
      res | sel≈ _   _   | sel₂ _   _   with p ≤ₚ? q
      res | sel≈ _   _   | sel₂ _   _   | yes _        = ≈ⁱ-refl
      res | sel≈ _   _   | sel₂ _   _   | no  _        with select x z | select y z
      res | sel≈ _   _   | sel₂ _   z≤y | no  _        | _            | sel₁ _   z≰y = contradiction z≤y z≰y
      res | sel≈ _   y≤x | sel₂ y≰z _   | no  _        | sel₁ x≤z _   | sel₂ _   _   = contradiction (≤ᵣ⇨≤ₗ comm (≤ᵣ-trans assoc y≤x (≤ₗ⇨≤ᵣ comm x≤z))) y≰z
      res | sel≈ _   _   | sel₂ _   _   | no  _        | sel₂ _   _   | sel₂ _   _   = ≈ⁱ-refl
      res | sel≈ _   y≤x | sel₂ y≰z _   | no  _        | sel≈ x≤z _   | sel₂ _   _   = contradiction (≤ᵣ⇨≤ₗ comm (≤ᵣ-trans assoc y≤x (≤ₗ⇨≤ᵣ comm x≤z))) y≰z
      res | sel≈ _   _   | sel₂ y≰z _   | no  _        | _            | sel≈ y≤z _   = contradiction y≤z y≰z
      res | sel≈ _   _   | sel≈ _   _   with p ≤ₚ? q | q ≤ₚ? r
      res | sel≈ _   _   | sel≈ _   _   | yes _        | yes _        with select x y | select x z
      res | sel≈ _   y≤x | sel≈ _   _   | yes _        | yes _        | sel₁ _   y≰x | _            = contradiction y≤x y≰x
      res | sel≈ x≤y _   | sel≈ _   _   | yes _        | yes _        | sel₂ x≰y _   | _            = contradiction x≤y x≰y
      res | sel≈ _   y≤x | sel≈ _   z≤y | yes _        | yes _        | sel≈ _   _   | sel₁ _   z≰x = contradiction (≤ᵣ-trans assoc z≤y y≤x) z≰x
      res | sel≈ x≤y _   | sel≈ y≤z _   | yes _        | yes _        | sel≈ _   _   | sel₂ x≰z _   = contradiction (≤ᵣ⇨≤ₗ comm (≤ᵣ-trans assoc (≤ₗ⇨≤ᵣ comm x≤y) (≤ₗ⇨≤ᵣ comm y≤z))) x≰z
      res | sel≈ _   _   | sel≈ _   _   | yes _        | yes _        | sel≈ _   _   | sel≈ _   _   with p ≤ₚ? q | p ≤ₚ? r
      res | sel≈ _   _   | sel≈ _   _   | yes _        | yes _        | sel≈ _   _   | sel≈ _   _   | yes _       | yes _      = ≈ⁱ-refl
      res | sel≈ _   _   | sel≈ _   _   | yes p≤q      | yes q≤r      | sel≈ _   _   | sel≈ _   _   | yes _       | no  p≰r    = contradiction (≤ₚ-trans p≤q q≤r) p≰r
      res | sel≈ _   _   | sel≈ _   _   | yes p≤q      | yes _        | sel≈ _   _   | sel≈ _   _   | no  p≰q     | _          = contradiction p≤q p≰q
      res | sel≈ _   _   | sel≈ _   _   | yes _        | no  _        = ≈ⁱ-refl
      res | sel≈ _   _   | sel≈ _   _   | no  _        | yes _        with select x y | select y z
      res | sel≈ _   y≤x | sel≈ _   _   | no  _        | yes _        | sel₁ _   y≰x | _            = contradiction y≤x y≰x
      res | sel≈ x≤y _   | sel≈ _   _   | no  _        | yes _        | sel₂ x≰y _   | _            = contradiction x≤y x≰y
      res | sel≈ _   _   | sel≈ _   z≤y | no  _        | yes _        | _            | sel₁ _   z≰y = contradiction z≤y z≰y
      res | sel≈ _   _   | sel≈ y≤z _   | no  _        | yes _        | _            | sel₂ y≰z _   = contradiction y≤z y≰z
      res | sel≈ _   _   | sel≈ _   _   | no  _        | yes _        | sel≈ _   _   | sel≈ _   _   with p ≤ₚ? q | q ≤ₚ? r
      res | sel≈ _   _   | sel≈ _   _   | no  p≰q      | yes _        | sel≈ _   _   | sel≈ _   _   | yes p≤q     | _          = contradiction p≤q p≰q
      res | sel≈ _   _   | sel≈ _   _   | no  _        | yes q≤r      | sel≈ _   _   | sel≈ _   _   | _           | no  q≰r    = contradiction q≤r q≰r
      res | sel≈ _   _   | sel≈ _   _   | no  _        | yes _        | sel≈ _   _   | sel≈ _   _   | no  _       | yes _      = ≈ⁱ-refl
      res | sel≈ _   _   | sel≈ _   _   | no  _        | no  _        with select x z | select y z
      res | sel≈ _   _   | sel≈ _   z≤y | no  _        | no  _        | _            | sel₁ _   z≰y = contradiction z≤y z≰y
      res | sel≈ _   _   | sel≈ y≤z _   | no  _        | no  _        | _            | sel₂ y≰z _   = contradiction y≤z y≰z
      res | sel≈ _   y≤x | sel≈ _   z≤y | no  _        | no  _        | sel₁ _   z≰x | sel≈ _   _   = contradiction (≤ᵣ-trans assoc z≤y y≤x) z≰x
      res | sel≈ x≤y _   | sel≈ y≤z _   | no  _        | no  _        | sel₂ x≰z _   | sel≈ _   _   = contradiction (≤ᵣ⇨≤ₗ comm (≤ᵣ-trans assoc (≤ₗ⇨≤ᵣ comm x≤y) (≤ₗ⇨≤ᵣ comm y≤z))) x≰z
      res | sel≈ _   _   | sel≈ _   _   | no  _        | no  _        | sel≈ _   _   | sel≈ _   _   with p ≤ₚ? r | q ≤ₚ? r
      res | sel≈ _   _   | sel≈ _   _   | no  _        | no  q≰r      | sel≈ _   _   | sel≈ _   _   | _           | yes q≤r    = contradiction q≤r q≰r
      res | sel≈ _   _   | sel≈ _   _   | no  _        | no  _        | sel≈ _   _   | sel≈ _   _   | no  _       | no  _      = ≈ⁱ-refl
      res | sel≈ _   _   | sel≈ _   _   | no  _        | no  _        | sel≈ _   _   | sel≈ _   _   | yes _       | no  _      with ≤ₚ-total p q
      res | sel≈ _   _   | sel≈ _   _   | no  p≰q      | no  _        | sel≈ _   _   | sel≈ _   _   | yes _       | no  _      | inj₁ p≤q = contradiction p≤q p≰q
      res | sel≈ _   _   | sel≈ _   _   | no  p≰q      | no  q≰r      | sel≈ _   _   | sel≈ _   _   | yes p≤r     | no  _      | inj₂ q≤p = contradiction (≤ₚ-trans q≤p p≤r) q≰r

    ----------------------
    -- Properties of ▷ⁱ --
    ----------------------

    ⊕ⁱ-almost-strictly-absorbs-▷ⁱ : (∀ s r → (s ▷ r) ⊕ r ≈ r) → ∀ s {r} → r ≉ⁱ inull → ((s ▷ⁱ r) ⊕ⁱ r ≈ⁱ r) × (r ≉ⁱ s ▷ⁱ r)
    ⊕ⁱ-almost-strictly-absorbs-▷ⁱ _   _       {inull}       r≉inull = contradiction inullEq r≉inull
    ⊕ⁱ-almost-strictly-absorbs-▷ⁱ abs (i , j) {iroute x []} _ with i ≟ᶠ j | (i , j) ∈? G
    ... | yes _   | _           = ≈ⁱ-refl , λ()
    ... | no  _   | no _        = ≈ⁱ-refl , λ()
    ... | no  i≢j | yes (v , _) with v ▷ x ≟ 0#
    ...   | yes _ = ≈ⁱ-refl , λ()
    ...   | no  _ with select (v ▷ x) x
    ...     | sel₁ _ vx⊕x≉x = contradiction (abs v x) vx⊕x≉x
    ...     | sel₂ _ _      = ≈ⁱ-refl , λ{(irouteEq x≈vx ())}
    ...     | sel≈ _ _      with [ i ∺ j ∣ i≢j ] ≤ₚ? []
    ...       | yes ()
    ...       | no  _ = ≈ⁱ-refl , λ{(irouteEq x≈vx ())}
    ⊕ⁱ-almost-strictly-absorbs-▷ⁱ abs (i , j) {iroute x [ p ]} _  with j ≟ᶠ source p | i ∉? [ p ] | (i , j) ∈? G
    ... | no  _ | _           | _           = ≈ⁱ-refl , λ()
    ... | yes _ | no  _       | _           = ≈ⁱ-refl , λ()
    ... | yes _ | yes _       | no  _       = ≈ⁱ-refl , λ()
    ... | yes _ | yes [ i∉p ] | yes (v , _)  with v ▷ x ≟ 0#
    ...   | yes _ = ≈ⁱ-refl , λ()
    ...   | no  _ with select (v ▷ x) x
    ...     | sel₁ _       vx⊕x≉x = contradiction (abs v x) vx⊕x≉x
    ...     | sel₂ vx⊕x≉vx _      = ≈ⁱ-refl , λ{(irouteEq _ [ p≈i∷p ]) → p≉i∷p p≈i∷p}
    ...     | sel≈ _       _      with [ i ∷ p ∣ i∉p ] ≤ₚ? [ p ]
    ...       | yes i∷p≤p = contradiction i∷p≤p i∷p≰p
    ...       | no  i∷p≰p = ≈ⁱ-refl , λ{(irouteEq _ [ p≈i∷p ]) → p≉i∷p p≈i∷p}

    postulate ▷ⁱ-extensionWitness : ∀ {s} r {x p} → s ▷ⁱ r ≈ⁱ iroute x p → ∃₂ λ y q → r ≈ⁱ iroute y q × length p ≡ suc (length q)
    
    postulate ▷ⁱ-size : ∀ {s} r {x p} → s ▷ⁱ r ≈ⁱ iroute x p → size (s ▷ⁱ r) ≡ suc (size r)

    postulate x≈y⇒|x|≡|y| : ∀ {x y} → x ≈ⁱ y → size x ≡ size y
    --▷-witness = {!!}


    -------------------------------------
    -- Adjacency and identity matrices --
    -------------------------------------
{-
    Iⁱᵢⱼ≡inull : ∀ {i j} → j ≢ i → Iⁱ i j ≡ inull
    Iⁱᵢⱼ≡inull {i} {j} j≢i with j ≟ᶠ i
    ... | yes j≡i = contradiction j≡i j≢i
    ... | no  _   = ≡-refl

    Iⁱᵢᵢ≡one[] : ∀ i → Iⁱ i i ≡ iroute one []
    Iⁱᵢᵢ≡one[] i with i ≟ᶠ i
    ... | no  i≢i = contradiction ≡-refl i≢i
    ... | yes i≡i = ≡-refl
-}

{-
    Iⁱᵢⱼ-idᵣ-⊕ⁱ : ∀ {i j} → j ≢ i → RightIdentity _≈ⁱ_ (Iⁱ i j) _⊕ⁱ_
    Iⁱᵢⱼ-idᵣ-⊕ⁱ j≢i inull        rewrite Iⁱᵢⱼ≡inull j≢i = ≈ⁱ-refl
    Iⁱᵢⱼ-idᵣ-⊕ⁱ j≢i (iroute _ _) rewrite Iⁱᵢⱼ≡inull j≢i = ≈ⁱ-refl

    Iⁱᵢⱼ-anᵣ-▷ⁱ : ∀ {i j} → j ≢ i → ∀ e → e ▷ⁱ Iⁱ i j ≈ⁱ Iⁱ i j
    Iⁱᵢⱼ-anᵣ-▷ⁱ j≢i inone     rewrite Iⁱᵢⱼ≡inull j≢i = inullEq
    Iⁱᵢⱼ-anᵣ-▷ⁱ j≢i (iedge _) rewrite Iⁱᵢⱼ≡inull j≢i = inullEq

    Iⁱᵢᵢ-almost-anᵣ-⊕ⁱ : RightZero _≈_ one _⊕_  → ∀ l s r → (s ▷ⁱ r) ⊕ⁱ Iⁱ l l ≈ⁱ Iⁱ l l
    Iⁱᵢᵢ-almost-anᵣ-⊕ⁱ _ _ inone     _     = ≈ⁱ-refl
    Iⁱᵢᵢ-almost-anᵣ-⊕ⁱ _ _ (iedge _) inull = ≈ⁱ-refl
    Iⁱᵢᵢ-almost-anᵣ-⊕ⁱ an l (iedge (i , j , v)) (iroute x p) with j ≟ᶠ source p | i ∉? p
    ... | no  _ | _     = ≈ⁱ-refl
    ... | yes _ | no  _ = ≈ⁱ-refl
    ... | yes _ | yes _ rewrite Iⁱᵢᵢ≡one[i] l with select (v ▷ x) one
    ...   | sel₁ _ vx⊕1≉1 = contradiction (an (v ▷ x)) vx⊕1≉1
    ...   | sel₂ _ _      = ≈ⁱ-refl
    ...   | sel≈ _ _      = ≈ⁱ-refl

    Aᵢⱼ▷inull≡inull : ∀ i j → Aⁱ i j ▷ⁱ inull ≡ inull
    Aᵢⱼ▷inull≡inull i j with G i j
    ... | nothing = ≡-refl
    ... | just _  = ≡-refl
-}

