open import Data.Nat using (ℕ; zero; suc; s≤s; _+_)
open import Data.Fin using (Fin; _<_; _≤_; inject₁) renaming (zero to fzero; suc to fsuc)
open import Algebra.FunctionProperties using (Op₂)
open import Data.Vec
open import Data.Product using (∃; ∃₂; _,_; _×_) renaming (map to mapₚ)
open import Data.List using ([]; _∷_)
open import Data.List.Any as Any using (here; there)
open import Data.List.Any.Membership.Propositional using () renaming (_∈_ to _∈ₗ_)
open import Function using (_∘_; id)
open import Relation.Nullary using (yes; no)
open import Relation.Nullary.Negation using (contradiction)
open import Relation.Binary using (Decidable)
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; refl; sym)

open import RoutingLib.Data.Vec

module RoutingLib.Data.Vec.Properties where

  -----------------------
  -- To push to stdlib --
  -----------------------

  ∈-lookup : ∀ {a n} {A : Set a} {v : A} {xs : Vec A n} → v ∈ xs → ∃ λ i → lookup i xs ≡ v
  ∈-lookup here = fzero , refl
  ∈-lookup (there v∈xs) = mapₚ fsuc id (∈-lookup v∈xs)

  ∈-lookup⁺ : ∀ {a n} {A : Set a} i (xs : Vec A n) → lookup i xs ∈ xs
  ∈-lookup⁺ fzero    (x ∷ xs) = here
  ∈-lookup⁺ (fsuc i) (x ∷ xs) = there (∈-lookup⁺ i xs)

  ∈-fromList⁻ : ∀ {a} {A : Set a} {v : A} {xs} → v ∈ fromList xs → v ∈ₗ xs
  ∈-fromList⁻ {xs = []}    ()
  ∈-fromList⁻ {xs = _ ∷ _} here         = here refl
  ∈-fromList⁻ {xs = _ ∷ _} (there v∈xs) = there (∈-fromList⁻ v∈xs)

  lookup-zipWith : ∀ {a n} {A : Set a} (_•_ : Op₂ A)
                   (i : Fin n) (xs ys : Vec A n) →
                   lookup i (zipWith _•_ xs ys) ≡ (lookup i xs) • (lookup i ys)
  lookup-zipWith _ fzero  (x ∷ _)  (y ∷ _)    = refl
  lookup-zipWith _•_ (fsuc i) (_ ∷ xs) (_ ∷ ys)  = lookup-zipWith _•_ i xs ys
