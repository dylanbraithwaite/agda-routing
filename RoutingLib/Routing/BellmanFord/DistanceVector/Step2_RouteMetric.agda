open import Relation.Nullary using (yes; no)
open import Relation.Nullary.Negation using (contradiction)
open import Relation.Binary using (_Preserves₂_⟶_⟶_)
open import Relation.Binary.PropositionalEquality using (_≡_; refl; sym; trans; cong; cong₂; subst₂; module ≡-Reasoning)
open import Data.List using (List; _∷_)
open import Data.List.Any.Membership.Propositional using (_∈_)
open import Data.Nat using (ℕ; suc; zero; z≤n; s≤s; _⊔_) renaming (_≤_ to _≤ℕ_; _<_ to _<ℕ_)
open import Data.Nat.Properties using (m≤m⊔n; n≤m⊔n; <⇒≢; ⊔-comm; ⊔-identityʳ; ⊔-mono-≤; ⊔-mono-<; module ≤-Reasoning) renaming (≤-reflexive to ≤ℕ-reflexive; ≤-refl to ≤ℕ-refl; ≤-trans to ≤ℕ-trans; ≤-antisym to ≤ℕ-antisym; ≤-decTotalOrder to ≤ℕ-decTotalOrder)
open import Data.Product using (∃)

open import RoutingLib.Data.List.Uniqueness.Propositional using (Unique)
open import RoutingLib.Data.List.Sorting using (Sorted)
open import RoutingLib.Data.Matrix using (Matrix; zipWith; max⁺)
open import RoutingLib.Data.Nat.Properties using (ℕₛ; m≤n⇒m≤n⊔o; n≤m⇒m⊔n≡m)
open import RoutingLib.Function.Distance using (IsUltrametric; MaxTriangleIneq)

open import RoutingLib.Routing.Definitions using (RoutingProblem; RoutingAlgebra)
open import RoutingLib.Routing.BellmanFord.DistanceVector.SufficientConditions
import RoutingLib.Routing.BellmanFord.DistanceVector.Prelude as Prelude
import RoutingLib.Routing.BellmanFord.DistanceVector.Step1_HeightFunction as Step1

module RoutingLib.Routing.BellmanFord.DistanceVector.Step2_RouteMetric
  {a b ℓ n-1}
  {𝓡𝓐 : RoutingAlgebra a b ℓ}
  (𝓡𝓟 : RoutingProblem 𝓡𝓐 (suc n-1)) 
  (𝓢𝓒 : SufficientConditions 𝓡𝓐)
  where
  
  open Prelude 𝓡𝓟 𝓢𝓒
  open Step1 𝓡𝓟 𝓢𝓒 using
    ( h
    ; h-resp-≈
    ; h-incr
    ; h-resp-≤
    ; h-resp-≤₂
    ; 1≤h
    )

  abstract

    ----------------------------
    -- distance between two routes
    
    d : Route → Route → ℕ
    d x y with x ≟ y
    ... | yes _ = zero
    ... | no  _ = h x ⊔ h y

    d-cong : d Preserves₂ _≈_ ⟶ _≈_ ⟶ _≡_
    d-cong {x} {y} {u} {v} x≈y u≈v with x ≟ u | y ≟ v
    ... | yes _   | yes _   = refl
    ... | yes x≈u | no  y≉v = contradiction (≈-trans (≈-trans (≈-sym x≈y) x≈u) u≈v) y≉v
    ... | no  x≉u | yes y≈v = contradiction (≈-trans (≈-trans x≈y y≈v) (≈-sym u≈v)) x≉u
    ... | no  _   | no  _   = cong₂ _⊔_ (h-resp-≈ x≈y) (h-resp-≈ u≈v)

    x≈y⇒d≡0 : ∀ {x y} → x ≈ y → d x y ≡ 0
    x≈y⇒d≡0 {x} {y} x≈y with x ≟ y
    ... | yes _   = refl
    ... | no  x≉y = contradiction x≈y x≉y

    d≡0⇒x≈y : ∀ {x y} → d x y ≡ 0 → x ≈ y
    d≡0⇒x≈y {x} {y} d≡0 with x ≟ y 
    ... | yes x≈y = x≈y
    ... | no  _   = contradiction (sym d≡0) (<⇒≢ (m≤n⇒m≤n⊔o (h y) (1≤h x)))
    
    d-sym : ∀ x y → d x y ≡ d y x
    d-sym x y with x ≟ y | y ≟ x
    ... | yes _   | yes _   = refl
    ... | no  x≉y | yes y≈x = contradiction (≈-sym y≈x) x≉y 
    ... | yes x≈y | no  y≉x = contradiction (≈-sym x≈y) y≉x 
    ... | no  _   | no  _   = ⊔-comm (h x) (h y)

    d-maxTriIneq : MaxTriangleIneq S d
    d-maxTriIneq x y z with x ≟ y | y ≟ z | x ≟ z
    ... | _       | _       | yes _  = z≤n
    ... | yes x≈y | yes y≈z | no x≉z = contradiction (≈-trans x≈y y≈z) x≉z
    ... | yes x≈y | no  _   | no _   = ≤ℕ-reflexive (cong₂ _⊔_ (h-resp-≈ x≈y) (refl {x = h z}))
    ... | no  _   | no  _   | no _   = ⊔-mono-≤ (m≤m⊔n (h x) (h y)) (n≤m⊔n (h y) (h z))
    ... | no  _   | yes y≈z | no _   = begin
      h x ⊔ h z     ≡⟨ cong (h x ⊔_) (h-resp-≈ (≈-sym y≈z)) ⟩
      h x ⊔ h y     ≡⟨ sym (⊔-identityʳ _) ⟩
      h x ⊔ h y ⊔ 0 ∎     
      where open ≤-Reasoning
    
    strIncr-lemma : ∀ f {x y} → x ≉ 0# → y ≈ 0# → h (f ▷ x) ⊔ h (f ▷ y) <ℕ h x ⊔ h y
    strIncr-lemma f {x} {y} x≉0 y≈0 = begin
      suc (h (f ▷ x) ⊔ h (f ▷ y))  ≡⟨ cong (λ v → suc (h (f ▷ x) ⊔ v)) (h-resp-≈ (▷-cong f y≈0)) ⟩
      suc (h (f ▷ x) ⊔ h (f ▷ 0#)) ≡⟨ cong (λ v → suc (h (f ▷ x) ⊔ v)) (h-resp-≈ (0#-an-▷ f)) ⟩
      suc (h (f ▷ x) ⊔ h 0#)       ≡⟨ cong suc (n≤m⇒m⊔n≡m (h-resp-≤ (0#-idₗ-⊕ _))) ⟩
      suc (h (f ▷ x))              ≤⟨ h-incr f x≉0 ⟩
      h x                          ≡⟨ sym (n≤m⇒m⊔n≡m (h-resp-≤ (0#-idₗ-⊕ _))) ⟩
      h x            ⊔ h 0#        ≡⟨ cong (h x ⊔_) (h-resp-≈ (≈-sym y≈0)) ⟩
      h x            ⊔ h y         ∎
      where open ≤-Reasoning
    
    d-strContr : ∀ f {x y} → x ≉ y → d (f ▷ x) (f ▷ y) <ℕ d x y
    d-strContr f {x} {y} x≉y with x ≟ y | f ▷ x ≟ f ▷ y
    ... | yes x≈y | _           = contradiction x≈y x≉y
    ... | no  _   | yes e▷x≈e▷y = m≤n⇒m≤n⊔o (h y) (1≤h x)
    ... | no  _   | no  _       with x ≟ 0# | y ≟ 0#
    ...   | yes x≈0 | yes y≈0 = contradiction (≈-trans x≈0 (≈-sym y≈0)) x≉y
    ...   | yes x≈0 | no  y≉0 = subst₂ _<ℕ_ (⊔-comm (h (f ▷ y)) (h (f ▷ x))) (⊔-comm (h y) (h x)) (strIncr-lemma f y≉0 x≈0)
    ...   | no  x≉0 | yes y≈0 = strIncr-lemma f x≉0 y≈0
    ...   | no  x≉0 | no  y≉0 = ⊔-mono-< (h-incr f x≉0) (h-incr f y≉0)

    d-mono : ∀ {x y a b} → y ≉ b → x ≤ y → a ≤ b → d x a  ≤ℕ d y b
    d-mono {x} {y} {a} {b} y≉b x≤y a≤b with x ≟ a | y ≟ b
    ... | yes _ | _       = z≤n
    ... | no  _ | yes y≈b = contradiction y≈b y≉b
    ... | no  _ | no  _   = ⊔-mono-≤ (h-resp-≤₂ x≤y) (h-resp-≤₂ a≤b)


    {-
    d-mono {u} {v} {x} {y} x≉y u≤x v≤y with u ≟ v | x ≟ y
    ... | yes _ | _       = z≤n
    ... | no  _ | yes x≈y = contradiction x≈y x≉y  --contradiction u≈v u≉v
    ... | no  _ | no  _   = ⊔-mono-≤ (h-resp-≤ {!!}) (h-resp-≤ {!!}) --
    -}
    
    d-isUltrametric : IsUltrametric S d
    d-isUltrametric = record 
      { eq⇒0        = x≈y⇒d≡0 
      ; 0⇒eq        = d≡0⇒x≈y 
      ; sym         = d-sym 
      ; maxTriangle = d-maxTriIneq 
      }
      

{-
    -----------------
    -- Ultrametric --
    -----------------
    -- We have now shown that d is an ultrametric

    D-isUltrametric : IsUltrametric ℝ𝕄ₛ D
    D-isUltrametric = record 
      { eq⇒0        = X≈Y⇒D≡0 
      ; 0⇒eq        = D≡0⇒X≈Y 
      ; sym         = D-sym 
      ; maxTriangle = D-maxTriIneq 
      }
-}
