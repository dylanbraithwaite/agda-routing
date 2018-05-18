open import Data.Nat using (ℕ; zero; suc; z≤n; s≤s; _+_; _∸_; _<_; _≤_)
open import Data.Nat.Properties using (+-identityʳ; +-suc; +-assoc; ≤-reflexive; <⇒≱; <-transˡ; m≤m+n)
open import Data.Fin using (Fin; zero; suc)
open import Data.Fin.Subset using (Subset; _∈_; _∉_; _∪_)
open import Data.Fin.Dec using (_∈?_)
open import Data.Sum using (_⊎_; inj₁; inj₂; [_,_]′)
open import Data.Product using (_,_; _×_; ∃; ∃₂; proj₁; proj₂)
open import Function using (_∘_)
open import Relation.Nullary using (Dec; ¬_; yes; no)
open import Relation.Nullary.Negation using (contradiction)
open import Relation.Unary using () renaming (_∈_ to _∈ᵤ_; _∉_ to _∉ᵤ_; _⊆_ to _⊆ᵤ_)
open import Relation.Binary.PropositionalEquality
  using (_≡_; _≢_; cong; subst; refl; sym; trans; inspect; [_])
import Relation.Binary.PartialOrderReasoning as POR
import Relation.Binary.EqReasoning as EqReasoning

open import RoutingLib.Data.Matrix using (SquareMatrix)
open import RoutingLib.Data.SimplePath
  using (SimplePath; []; _∷_∣_∣_; invalid; valid; notThere; notHere; continue; length)
  renaming (_∈_ to _∈ₚ_)
open import RoutingLib.Data.SimplePath.Relation.Equality
open import RoutingLib.Data.SimplePath.Relation.Subpath
open import RoutingLib.Data.SimplePath.All
open import RoutingLib.Data.SimplePath.Properties
  using (∉-resp-≈ₚ; length-cong)
open import RoutingLib.Data.Fin.Subset using (Nonfull)
open import RoutingLib.Data.Nat.Properties using (module ≤-Reasoning)

open import RoutingLib.Routing.Algebra
import RoutingLib.Routing.BellmanFord.SyncConvergenceRate.PathVector.Prelude as Prelude
import RoutingLib.Routing.BellmanFord.SyncConvergenceRate.PathVector.Step1_NodeSets as Step1_NodeSets
import RoutingLib.Routing.BellmanFord.SyncConvergenceRate.PathVector.Step2_ConvergedSubtree as Step2_ConvergedSubtree
import RoutingLib.Routing.BellmanFord.SyncConvergenceRate.PathVector.Step3_DangerousNodes as Step3_DangerousNodes
open IncreasingPathAlgebra using (Route)

module RoutingLib.Routing.BellmanFord.SyncConvergenceRate.PathVector.Step4_InductiveStep
  {a b ℓ n-1} (algebra : IncreasingPathAlgebra a b ℓ (suc n-1))
  (X : SquareMatrix (Route algebra) (suc n-1))
  (j : Fin (suc n-1))
  (t-1 : ℕ)
  {C : Subset (suc n-1)}
  (j∈C : j ∈ C)
  (C-nonfull : Nonfull C)
  (C⊆𝓒ₜ : ∀ {i} → i ∈ C → i ∈ᵤ Step1_NodeSets.𝓒 algebra X j (suc t-1))
  where
  
  open Prelude algebra
  open Notation X j
  open Step1_NodeSets algebra X j
  open Step2_ConvergedSubtree algebra X j t-1 j∈C C-nonfull C⊆𝓒ₜ
  open Step3_DangerousNodes algebra X j t-1 j∈C C-nonfull C⊆𝓒ₜ
  
  --------------------------------------------------------------------------
  -- Some lemmas

  private

    t : ℕ
    t = suc t-1

  ------------------------------------------------------------------------
  -- Therefore at time (t + n) there is no more dangerous junk

  iₘᵢₙ-pred≤ : ∀ s → A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + n-1 + s) X kₘᵢₙ j ≤₊ σ^ (suc (t + n-1 + s)) X iₘᵢₙ j
  iₘᵢₙ-pred≤ s with σXᵢⱼ≈Aᵢₖ▷Xₖⱼ⊎Iᵢⱼ (σ^ (t + n-1 + s) X) iₘᵢₙ j
  ... | inj₂ σXᵢⱼ≈Iᵢⱼ    = begin
    A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + n-1 + s) X kₘᵢₙ j ≤⟨ ⊕-identityˡ _ ⟩
    ∞                                       ≈⟨ ≈-reflexive (sym (Iᵢⱼ≡∞ j≢iₘᵢₙ)) ⟩
    I iₘᵢₙ j                                ≈⟨ ≈-sym σXᵢⱼ≈Iᵢⱼ ⟩
    σ^ (suc (t + n-1 + s)) X iₘᵢₙ j         ∎
    where open POR ≤₊-poset
  ... | inj₁ (k , σXᵢⱼ≈AᵢₖXₖⱼ) with eₘᵢₙ ≤[ t + (n-1 + s) ]? (iₘᵢₙ , k)
  ...   | yes eₘᵢₙ≤e = begin
    A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + n-1 + s)   X kₘᵢₙ j ≈⟨ ≈-reflexive (cong (λ v → A iₘᵢₙ kₘᵢₙ ▷ σ^ v X kₘᵢₙ j) (+-assoc t n-1 s)) ⟩
    A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + (n-1 + s)) X kₘᵢₙ j ≤⟨ eₘᵢₙ≤e ⟩
    A iₘᵢₙ k    ▷ σ^ (t + (n-1 + s)) X k    j ≈⟨ ≈-reflexive (cong (λ v → A iₘᵢₙ k ▷ σ^ v X k j) (sym (+-assoc t n-1 s))) ⟩
    A iₘᵢₙ k    ▷ σ^ (t + n-1 + s)   X k    j ≈⟨ ≈-sym σXᵢⱼ≈AᵢₖXₖⱼ ⟩
    σ^ (suc (t + n-1 + s)) X iₘᵢₙ j           ∎
    where open POR ≤₊-poset
  ...   | no  eₘᵢₙ≰e with 𝓡? (t + (n-1 + s)) k
  ...     | no  k∉R = contradiction
    (𝓓-length (n-1 + s) (k∉R , (iₘᵢₙ , ≰₊⇒>₊ eₘᵢₙ≰e)))
    (<⇒≱ (<-transˡ (lengthₑ<n (t + (n-1 + s)) (iₘᵢₙ , k)) (m≤m+n n s)))
  ...     | yes k∈R with k ∈? C
  ...       | yes  k∈C = contradiction (eₘᵢₙ-isMinₜ₊ₛ (iₘᵢₙ∉C , k∈C) (n-1 + s)) eₘᵢₙ≰e
  ...       | no   k∉C = contradiction (∈𝓡 (n-1 + s) iₘᵢₙ k∈R k∉C ≈ₚ-refl) eₘᵢₙ≰e


  iₘᵢₙ-pred : ∀ s → σ^ (t + n + s) X iₘᵢₙ j ≈ A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + (n-1 + s)) X kₘᵢₙ j
  iₘᵢₙ-pred s = begin
    σ^ (t + n + s) X iₘᵢₙ j                   ≡⟨ cong (λ v → σ^ (v + s) X iₘᵢₙ j) (+-suc t n-1) ⟩
    σ^ (suc t + n-1 + s) X iₘᵢₙ j             ≈⟨ ≤₊-antisym (σXᵢⱼ≤Aᵢₖ▷Xₖⱼ
                                                (σ^ (t + n-1 + s) X) iₘᵢₙ j kₘᵢₙ) (iₘᵢₙ-pred≤ s) ⟩
    A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + n-1 + s) X kₘᵢₙ j   ≡⟨ cong (λ v → A iₘᵢₙ kₘᵢₙ ▷ σ^ v X kₘᵢₙ j) (+-assoc t n-1 s) ⟩
    A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + (n-1 + s)) X kₘᵢₙ j ∎
    where open EqReasoning S
    

  private

    lemma₄ : ∀ {p} → path (σ^ (t + n) X iₘᵢₙ j) ≡ p →
             path (A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + n-1) X kₘᵢₙ j) ≈ₚ p
    lemma₄ {p} eq = begin
      path (A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + n-1)     X kₘᵢₙ j)   ≡⟨ cong (λ v → path (A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + v) X kₘᵢₙ j)) (sym (+-identityʳ n-1)) ⟩
      path (A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + (n-1 + 0)) X kₘᵢₙ j) ≈⟨ path-cong (≈-sym (iₘᵢₙ-pred 0)) ⟩
      path (σ^ (t + n + 0) X iₘᵢₙ j)                   ≡⟨ cong (λ v → path (σ^ v X iₘᵢₙ j)) (+-identityʳ (t + n)) ⟩
      path (σ^ (t + n) X iₘᵢₙ j)                       ≡⟨ eq ⟩
      p                                                ∎
      where open EqReasoning (ℙₛ n)


  iₘᵢₙ∈𝓕ₜ₊ₙ : iₘᵢₙ ∈ᵤ 𝓕 (t + n)
  iₘᵢₙ∈𝓕ₜ₊ₙ s = begin
    σ^ (t + n + s) X iₘᵢₙ j                    ≈⟨ iₘᵢₙ-pred s ⟩
    A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + (n-1 + s)) X kₘᵢₙ j  ≈⟨ ▷-cong (A iₘᵢₙ kₘᵢₙ)
                                                  (𝓒-eq t kₘᵢₙ (n-1 + s) (n-1 + 0) kₘᵢₙ∈𝓒ₜ) ⟩
    A iₘᵢₙ kₘᵢₙ ▷ σ^ (t + (n-1 + 0)) X kₘᵢₙ j  ≈⟨ ≈-sym (iₘᵢₙ-pred 0) ⟩
    σ^ (t + n + 0) X iₘᵢₙ j                   ≡⟨ cong (λ v → σ^ v X iₘᵢₙ j) (+-identityʳ (t + n)) ⟩
    σ^ (t + n)     X iₘᵢₙ j                   ∎
    where open EqReasoning S

  p[iₘᵢₙ]∈𝓕ₜ₊ₙ : Allₙ (𝓕 (t + n)) (path (σ^ (t + n) X iₘᵢₙ j))
  p[iₘᵢₙ]∈𝓕ₜ₊ₙ with path (σ^ (t + n) X iₘᵢₙ j) | inspect path (σ^ (t + n) X iₘᵢₙ j)
  ... | invalid                     | _ = invalid
  ... | valid []                    | _ = valid []
  ... | valid ((_ , _) ∷ p ∣ _ ∣ _) | [ p[σᵗ⁺ⁿ]≡iₘk∷p ]
    with alignPathExtension (σ^ (t + n-1) X) iₘᵢₙ j kₘᵢₙ (lemma₄ p[σᵗ⁺ⁿ]≡iₘk∷p)
  ...   | refl , refl , p[σᵗ⁺ⁿ⁻¹Xₖⱼ]≈p with 𝓒ₜ⊆𝓒ₜ₊ₛ t n kₘᵢₙ∈𝓒ₜ
  ...     | (k∈S , pₖ∈S) with Allₙ-resp-≈ₚ pₖ∈S (≈ₚ-trans (path-cong (𝓒-eq t _ n n-1 kₘᵢₙ∈𝓒ₜ)) p[σᵗ⁺ⁿ⁻¹Xₖⱼ]≈p)
  ...       | valid p∈S = valid ([ iₘᵢₙ∈𝓕ₜ₊ₙ , k∈S ]∷ p∈S)

  iₘᵢₙ∈𝓒ₜ₊ₙ : iₘᵢₙ ∈ᵤ 𝓒 (t + n)
  iₘᵢₙ∈𝓒ₜ₊ₙ = iₘᵢₙ∈𝓕ₜ₊ₙ , p[iₘᵢₙ]∈𝓕ₜ₊ₙ
