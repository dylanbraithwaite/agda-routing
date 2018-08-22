open import Data.Nat using (ℕ; _<_)
open import Data.Fin using (Fin)
open import Level using () renaming (zero to ℓ₀)
open import Relation.Binary using (Rel)
open import Relation.Binary.PropositionalEquality using (_≡_)
open import Relation.Nullary using (¬_)
open import Relation.Unary using (Pred)

open import RoutingLib.Data.Path.Uncertified.FiniteEdge.NonEmpty using (Pathⁿᵗ; length; _≈ₚ_; _<ₗₑₓ_)
open import RoutingLib.Routing.BellmanFord.Models.BGPLite.Communities

module RoutingLib.Routing.BellmanFord.Models.BGPLite.Route (n : ℕ) where

-----------
-- Types --
-----------

Level : Set
Level = ℕ

Node : Set
Node = Fin n

data Route : Set where
  invalid : Route
  valid   : (l : ℕ) → (cs : CommunitySet) → (p : Pathⁿᵗ n) → Route

--------------
-- Equality --
--------------

infix 4 _≈ᵣ_ _≉ᵣ_

data _≈ᵣ_ : Rel Route ℓ₀ where
  invalidEq : invalid ≈ᵣ invalid
  validEq   : ∀ {k l cs ds p q} → k ≡ l → cs ≈ᶜˢ ds → p ≈ₚ q → valid k cs p ≈ᵣ valid l ds q

_≉ᵣ_ : Rel Route ℓ₀
r ≉ᵣ s = ¬ (r ≈ᵣ s)

----------------------
-- Preference order --
----------------------

infix 4 _≤ᵣ_ _≰ᵣ_

data _≤ᵣ_ : Rel Route ℓ₀ where
  invalid : ∀ {r} → r ≤ᵣ invalid
  level<  : ∀ {k l cs ds p q} → k < l → valid k cs p ≤ᵣ valid l ds q
  length< : ∀ {k l cs ds p q} → k ≡ l → length p < length q → valid k cs p ≤ᵣ valid l ds q
  plex<   : ∀ {k l cs ds p q} → k ≡ l → length p ≡ length q → p <ₗₑₓ q → valid k cs p ≤ᵣ valid l ds q
  comm≤   : ∀ {k l cs ds p q} → k ≡ l → p ≈ₚ q → cs ≤ᶜˢ ds → valid k cs p ≤ᵣ valid l ds q

_≰ᵣ_ : Rel Route ℓ₀
r ≰ᵣ s = ¬ (r ≤ᵣ s)

--------------
-- Validity --
--------------

data IsValid : Pred Route ℓ₀ where
  isValid : ∀ {l cs p} → IsValid (valid l cs p)
