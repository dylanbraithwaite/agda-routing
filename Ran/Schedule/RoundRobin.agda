module Schedule.RoundRobin where

  -- imports
  open import Schedule
    using (Schedule; 𝕋)
  open import Data.Nat
    using (ℕ; zero; suc; _≤_; _<_; _+_; _∸_)
  open import Data.Fin
    using (Fin; toℕ) renaming (zero to fzero; suc to fsuc)
  open import Data.Fin.Subset
    using (Subset; _∈_; ⊤; ⁅_⁆)
  open import Relation.Binary.PropositionalEquality
    using (_≡_; _≢_; refl; subst; cong; sym; trans)
  open import Data.Product
    using(∃; _,_)
  open import Data.Nat.DivMod
    using (_mod_)
  open import Data.Fin.Subset.Properties
    using (∈⊤; x∈⁅x⁆)
  open import Data.Nat.Properties
    using (+-identityˡ; +-comm)
  open import Schedule.Synchronous
    using (β; causality; finite; α₀)
  open import Function.Equivalence
    using (Equivalence)
  open import Data.Vec
    using (Vec; tabulate; lookup)

  -- Round Robin Schedule Functions
  α : {n : ℕ} → 𝕋 → Subset (suc n)
  α zero = ⊤
  α {n} (suc t) = ⁅ t mod (suc n) ⁆

  postulate i-mod-n≡i : ∀ {n} (i : Fin (suc n)) → i ≡ (toℕ i) mod (suc n)

  postulate mod-properties : ∀ {n} t (i : Fin (suc n)) → i ≡ (t + suc (n + (toℕ i) ∸ (toℕ (t mod (suc n))))) mod (suc n)
  
  nonstarvation : {n : ℕ} → ∀ t (i : Fin (suc n)) → ∃ λ k →  (i ∈ (α (t + suc k)))
  nonstarvation {n} zero i = toℕ i , subst (i ∈_) (cong ⁅_⁆ (i-mod-n≡i i)) (x∈⁅x⁆ i)
  nonstarvation {n} (suc t) i = n + (toℕ i) ∸ (toℕ (t mod (suc n))) ,
                subst (i ∈_) (cong ⁅_⁆ (mod-properties t i)) (x∈⁅x⁆ i)

  -- Round Robin Schedule
  rr-schedule : (n : ℕ) → Schedule (suc n)
  rr-schedule n = record {
    α = α ;
    α₀ = α₀ ;
    β = β ;
    causality = causality ;
    nonstarvation = nonstarvation ;
    finite = finite
    }


  schedule : Schedule 10
  schedule = rr-schedule 9

  open Schedule.Timing schedule

  x : Vec 𝕋 10
  x = tabulate (λ i → φ (toℕ i))

  a : Fin 10
  a = fsuc (fsuc (fsuc (fsuc fzero)))
