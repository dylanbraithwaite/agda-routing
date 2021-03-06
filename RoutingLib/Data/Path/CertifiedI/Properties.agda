open import Data.Maybe
open import Data.Nat using (ℕ; suc; z≤n; s≤s) renaming (_≟_ to _≟ℕ_; _≤?_ to _≤ℕ?_; _≤_ to _≤ℕ_; _<_ to _<ℕ_)
open import Data.Nat.Properties using (<-trans; ≤-trans; m≢1+m+n; <⇒≢; <⇒≯; ≤-refl; m+n≮n; suc-injective; <-cmp)
open import Data.Fin using (Fin; _<_; _≤?_; suc; zero)
open import Data.Fin.Properties using (cmp; ≤-antisym; ≤-total; _<?_)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Data.Product using (_,_; _×_)
open import Level using () renaming (zero to 0ℓ)
open import Relation.Binary using (Decidable; Total; _⇒_; Reflexive; Symmetric; Antisymmetric; Transitive; _Respects_; tri≈; tri<; tri>; IsEquivalence; IsDecEquivalence; Setoid; DecSetoid; _Preserves_⟶_)
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; refl; sym; trans; subst; cong)
open import Relation.Nullary using (¬_; yes; no)
open import Relation.Nullary.Negation using (contradiction)

open import RoutingLib.Data.Maybe
open import RoutingLib.Data.Nat.Properties using (n≢1+n)


open import RoutingLib.Data.Path.CertifiedI
import RoutingLib.Data.Path.Certified.Properties as CertifiedProperties

module RoutingLib.Data.Path.CertifiedI.Properties where

open CertifiedProperties public
  using ()
  renaming
  ( _⇿?_        to _⇿ᵥ?_
  ; _∉ₚ?_       to _∉ᵥₚ?_
  ; ⇿-resp-≈ₚ   to ⇿ᵥ-resp-≈ᵥₚ
  ; ∉ₚ-resp-≈ₚ  to ∉ᵥₚ-resp-≈ᵥₚ
  ; p≉i∷p       to p≉ᵛi∷p
  ; ≈ₚ-refl     to ≈ₚᵛ-refl
  ; ≈ₚ-sym      to ≈ₚᵛ-sym
  ; ≈ₚ-trans    to ≈ₚᵛ-trans
  ; ℙₛ          to ℙᵛₛ
  ; length-cong to lengthᵛ-cong
  ; |p|<n       to |pᵛ|<n
  ; |p|≤1+n     to |pᵛ|≤1+n
  )

----------------------------------------------------------------------------
-- Linkage

infix 4 _⇿?_

_⇿?_ : ∀ {n} → Decidable (_⇿_ {n})
e ⇿? p = anyDec (e ⇿ᵥ?_) p

⇿-resp-≈ₚ : ∀ {n} {e : Edge n} → (e ⇿_) Respects _≈ₚ_
⇿-resp-≈ₚ invalid     e⇿p         = e⇿p
⇿-resp-≈ₚ (valid p≈q) (valid e⇿p) = valid (⇿ᵥ-resp-≈ᵥₚ p≈q e⇿p)

----------------------------------------------------------------------------
-- Membership

_∉ₚ?_ : ∀ {n} → Decidable (_∉ₚ_ {n})
k ∉ₚ? p = allDec (k ∉ᵥₚ?_) p

∉ₚ-resp-≈ₚ : ∀ {n} {k : Fin n} → (k ∉ₚ_) Respects _≈ₚ_
∉ₚ-resp-≈ₚ invalid     invalid     = invalid
∉ₚ-resp-≈ₚ (valid p≈q) (valid k∉p) = valid (∉ᵥₚ-resp-≈ᵥₚ p≈q k∉p)

{-
∈-resp-≈ₚ : ∀ {k : Fin n} → (k ∈_) Respects _≈ₚ_
∈-resp-≈ₚ x≈y k∈x k∉y = k∈x (∉-resp-≈ₚ {!≈ₚ-sym ?!} k∉y)
-}

----------------------------------------------------------------------------
-- Equality

module _ {n : ℕ} where

  valid-injective : ∀ {p q : Pathᵛ n} → valid p ≈ₚ valid q → p ≈ᵥₚ q
  valid-injective (valid p≈q) = p≈q


  p≉i∷p : ∀ {e} {p : Pathᵛ n} {e⇿p e∉p} → valid p ≉ₚ valid (e ∷ p ∣ e⇿p ∣ e∉p)
  p≉i∷p (valid v) = p≉ᵛi∷p v

  ≈ₚ-refl : Reflexive (_≈ₚ_ {n})
  ≈ₚ-refl = Eq-refl ≈ₚᵛ-refl

  ≈ₚ-reflexive : _≡_ ⇒ (_≈ₚ_ {n})
  ≈ₚ-reflexive refl = ≈ₚ-refl

  ≈ₚ-sym : Symmetric (_≈ₚ_ {n})
  ≈ₚ-sym = Eq-sym ≈ₚᵛ-sym

  ≈ₚ-trans : Transitive (_≈ₚ_ {n})
  ≈ₚ-trans = Eq-trans ≈ₚᵛ-trans
{-
  _≟ₚ_ : Decidable (_≈ₚ_ {n})
  invalid ≟ₚ invalid = yes invalid
  invalid ≟ₚ valid q = no λ()
  valid p ≟ₚ invalid  = no λ()
  valid p ≟ₚ valid q with NEP._≟ₚ_ p q
  ... | no  p≉q = no (λ{(valid p≈q) → p≉q p≈q})
  ... | yes p≈q = yes (valid p≈q)
-}
module _ (n : ℕ) where

  ≈ₚ-isEquivalence : IsEquivalence (_≈ₚ_ {n})
  ≈ₚ-isEquivalence = record
    { refl  = ≈ₚ-refl
    ; sym   = ≈ₚ-sym
    ; trans = ≈ₚ-trans
    }
{-
  ≈ₚ-isDecEquivalence : IsDecEquivalence (_≈ₚ_ {n})
  ≈ₚ-isDecEquivalence = record
    { isEquivalence = ≈ₚ-isEquivalence
    ; _≟_           = _≟ₚ_
    }
-}
  ℙₛ : Setoid 0ℓ 0ℓ
  ℙₛ = record { isEquivalence = ≈ₚ-isEquivalence }
{-
  ℙₛ? : DecSetoid 0ℓ 0ℓ
  ℙₛ? = record { isDecEquivalence = ≈ₚ-isDecEquivalence }
-}

----------------------------------------------------------------------------
-- Length

|p|<n : ∀ {n} (p : Path (suc n)) → length p <ℕ suc n
|p|<n invalid                     = s≤s z≤n
|p|<n (valid [])                  = s≤s z≤n
|p|<n (valid (e ∷ p ∣ e⇿p ∣ e∉p)) = |pᵛ|<n (nonEmpty e p e⇿p e∉p)

|p|≤1+n : ∀ {n} (p : Path n) → length p ≤ℕ suc n
|p|≤1+n invalid   = z≤n
|p|≤1+n (valid p) = |pᵛ|≤1+n p

length-cong : ∀ {n} {p q : Path n} → p ≈ₚ q → length p ≡ length q
length-cong invalid     = refl
length-cong (valid p≈q) = lengthᵛ-cong p≈q
