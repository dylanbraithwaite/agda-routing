open import Data.Nat using (ℕ; zero; suc; z≤n; s≤s; _<_)
open import Data.Fin using (Fin; zero; suc)
open import Data.Fin.Properties using (_≟_; suc-injective)
open import Data.Fin.Dec using (any?)
open import Data.Product using (_×_; ∃₂; _,_)
open import Data.Vec using (tabulate; toList; allFin)
open import Relation.Binary.PropositionalEquality using (cong; _≡_; _≢_; refl)
open import Relation.Nullary using (yes; no)
open import Relation.Nullary.Negation using (contradiction)
open import Function using (_∘_)

------------------------------------------------------------------------

module RoutingLib.Data.Fin.Pigeonhole where

  -- Returns if i < j then j-1 else j
  punchout : ∀ {m} {i j : Fin (suc m)} → i ≢ j → Fin m
  punchout {_}     {zero}   {zero}  i≢j = contradiction refl i≢j
  punchout {_}     {zero}   {suc j} _   = j
  punchout {zero}  {suc ()}
  punchout {suc n} {suc i}  {zero}  _   = zero
  punchout {suc n} {suc i}  {suc j} i≢j = suc (punchout (i≢j ∘ cong suc))

  punchout-inj : ∀ {m} {i j k : Fin (suc m)} (i≢j : i ≢ j) (i≢k : i ≢ k) → punchout i≢j ≡ punchout i≢k → j ≡ k
  punchout-inj {_}     {zero}   {zero}  {_}     i≢j _   _    = contradiction refl i≢j
  punchout-inj {_}     {zero}   {_}     {zero}  _   i≢k _    = contradiction refl i≢k
  punchout-inj {_}     {zero}   {suc j} {suc k} _   _   pⱼ≡pₖ = cong suc pⱼ≡pₖ
  punchout-inj {zero}  {suc ()}
  punchout-inj {suc n} {suc i}  {zero}  {zero}  _   _    _   = refl
  punchout-inj {suc n} {suc i}  {zero}  {suc k} _   _   ()
  punchout-inj {suc n} {suc i}  {suc j} {zero}  _   _   ()
  punchout-inj {suc n} {suc i}  {suc j} {suc k} i≢j i≢k pⱼ≡pₖ = cong suc (punchout-inj (i≢j ∘ cong suc) (i≢k ∘ cong suc) (suc-injective pⱼ≡pₖ))

  pigeonhole : ∀ {m n} → m < n → (f : Fin n → Fin m) → ∃₂ (λ i j → i ≢ j × f i ≡ f j)
  pigeonhole (s≤s z≤n) f with f zero
  ... | ()
  pigeonhole (s≤s (s≤s m≤n)) f with any? ((_≟_ (f zero)) ∘ f ∘ suc)
  ... | yes (j , f₀≡fⱼ₊₁) = zero , suc j , (λ()) , f₀≡fⱼ₊₁
  ... | no  ∄k[f₀≡fₖ₊₁] with pigeonhole (s≤s m≤n) (λ j → punchout (∄k[f₀≡fₖ₊₁] ∘ (j ,_ )))
  ...    | (i , j , i≢j , fᵢ≡fⱼ) = (suc i , suc j , i≢j ∘ suc-injective , punchout-inj (∄k[f₀≡fₖ₊₁] ∘ (i ,_)) (∄k[f₀≡fₖ₊₁] ∘ (j ,_)) fᵢ≡fⱼ)

