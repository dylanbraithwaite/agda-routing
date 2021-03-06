--------------------------------------------------------------------------------
-- Defines another algebra that is slightly better behaved than that of the main
-- BGPLite algebra. It is however identical in operation. This allows the
-- BGPLite algebra to be proved convergent via this algebra being shown to be
-- convergent.
--------------------------------------------------------------------------------

module RoutingLib.Routing.Protocols.PathVector.BGPLite.Simulation where

open import Data.Maybe using (just; nothing; Is-just; just-injective)
open import Data.Nat using (_≤_)
open import Data.Nat.Properties using (≤-refl; <-cmp; <-transˡ)
open import Data.List.Properties using (∷-injectiveˡ)
open import Data.Fin using (Fin; toℕ)
open import Data.Fin.Properties using (toℕ-injective)
open import Data.Product using (∃; ∃₂; _×_; _,_)
open import Data.Product.Properties using (,-injectiveʳ)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Function using (id; _∘_; _$_)
open import Relation.Binary using (tri<; tri≈; tri>)
open import Relation.Binary.PropositionalEquality
open import Relation.Nullary using (¬_; yes; no)
open import Relation.Nullary.Negation using (contradiction)

open import RoutingLib.Data.Path.UncertifiedI using (Path; invalid; valid; source; sourceᵥ)
open import RoutingLib.Data.Path.UncertifiedI.Properties using (valid-injective)
open import RoutingLib.Data.Path.Uncertified using ([]; _∷_; inflate; deflate; length; _⇿_; _∈ₚ_)
open import RoutingLib.Data.Path.Uncertified.Properties
import RoutingLib.Algebra.Construct.NaturalChoice.Min.TotalOrder as Min

open import RoutingLib.Routing.Algebra
open import RoutingLib.Routing.Protocols.PathVector.BGPLite
open import RoutingLib.Routing.Protocols.PathVector.BGPLite.Components.Policy
  using (apply; apply-result)
open import RoutingLib.Routing.Protocols.PathVector.BGPLite.Components.Route
open import RoutingLib.Routing.Protocols.PathVector.BGPLite.Components.Communities

open ≡-Reasoning

--------------------------------------------------------------------------------
-- The simulating algebra
--
-- The algebra is identical to the algebra of BGPLite except for a different
-- choice operator. This new operator is fully associative, rather than just
-- associative over comparable routes. As proving associativity of an operator
-- requires O(n³) cases, this is instead implemented via the natural choice
-- operation for the associated total order. The order can be proved to be
-- transitive in O(n²) operations, and hence the operator is transitive.

open Min ≤ᵣ-totalOrder public
  using () renaming (_⊓_ to _⊕ₐₗₜ_; ⊓-cong to ⊕ₐₗₜ-cong)

Aₐₗₜ : RawRoutingAlgebra _ _ _
Aₐₗₜ = record
  { Route              = Route
  ; Step               = Step
  ; _≈_                = _≡_
  ; _⊕_                = _⊕ₐₗₜ_
  ; _▷_                = _▷_
  ; 0#                 = 0#
  ; ∞#                 = ∞#
  ; f∞                 = f∞
  ; ≈-isDecEquivalence = ≡ᵣ-isDecEquivalence
  ; ⊕-cong             = ⊕ₐₗₜ-cong
  ; ▷-cong             = ▷-cong
  ; f∞-reject          = f∞-reject
  }

--------------------------------------------------------------------------------
-- The algebra Aₐₗₜ is a routing algebra

open Min ≤ᵣ-totalOrder
  renaming
  ( ⊓-sel       to ⊕ₐₗₜ-sel
  ; ⊓-comm      to ⊕ₐₗₜ-comm
  ; ⊓-assoc     to ⊕ₐₗₜ-assoc
  ; ⊓-zeroʳ     to ⊕ₐₗₜ-zeroʳ
  ; ⊓-identityʳ to ⊕ₐₗₜ-identityʳ
  ; ⊓-identityˡ to ⊕ₐₗₜ-identityˡ
  )

▷-fixedPoint : ∀ {n} {i j : Fin n} (f : Step i j) → f ▷ invalid ≡ invalid
▷-fixedPoint (step _) = refl

▷-result : ∀ {n} {i j : Fin n} (f : Step i j) l cs p →
           f ▷ (valid l cs p) ≡ invalid ⊎
             ∃₂ λ k ds → ∃ λ m → l ≤ k × f ▷ (valid l cs p) ≡ valid k ds (inflate ((toℕ i , toℕ j) ∷ p) m) 
▷-result {n} {i} {j} (step pol) l cs p with (toℕ i , toℕ j) ⇿? p | toℕ i ∈ₚ? p
... | no  _    | _       = inj₁ refl
... | yes _    | yes _   = inj₁ refl
... | yes ij⇿p | no  i∈p = apply-result pol l cs ((toℕ i , toℕ j) ∷ p)

isIncreasing : IsIncreasing Aₐₗₜ
isIncreasing {_} {_} {_} f invalid        = refl
isIncreasing {_} {i} {j} f (valid l cs p) with ▷-result f l cs p
... | inj₁ f▷v≡i                      = ⊕ₐₗₜ-cong f▷v≡i refl
... | inj₂ (k , ds , m , l≤k , f▷v≡r) with ≤ᵣ-total (f ▷ valid l cs p) (valid l cs p)
...   | inj₂ v≤f▷v = refl
...   | inj₁ f▷v≤v = contradiction
  (subst (_≤ᵣ _) f▷v≡r f▷v≤v)
  (≤ᵣ-reject l≤k (<-transˡ ≤-refl (inflate-length _ m)))

isRoutingAlgebra : IsRoutingAlgebra Aₐₗₜ
isRoutingAlgebra = record
  { ⊕-sel        = ⊕ₐₗₜ-sel
  ; ⊕-comm       = ⊕ₐₗₜ-comm
  ; ⊕-assoc      = ⊕ₐₗₜ-assoc
  ; ⊕-zeroʳ      = ⊕ₐₗₜ-zeroʳ     ≤ᵣ-minimum
  ; ⊕-identityʳ  = ⊕ₐₗₜ-identityʳ ≤ᵣ-maximum
  ; ▷-fixedPoint = ▷-fixedPoint
  }

--------------------------------------------------------------------------------
-- The algebra Aₐₗₜ is a path algebra

path : Route → Path
path invalid       = invalid
path (valid _ _ p) = valid (deflate p)

r≈0⇒path[r]≈[] : ∀ {r} → r ≡ 0# → path r ≡ valid []
r≈0⇒path[r]≈[] refl = refl

r≈∞⇒path[r]≈∅ : ∀ {r} → r ≡ invalid → path r ≡ invalid
r≈∞⇒path[r]≈∅ refl = refl

path[r]≈∅⇒r≈∞ : ∀ {r} → path r ≡ invalid → r ≡ invalid
path[r]≈∅⇒r≈∞ {invalid}      refl = refl
path[r]≈∅⇒r≈∞ {valid l cs p} ()

path-reject : ∀ {n} {i j : Fin n} {r q} (f : Step i j) → path r ≡ valid q →
              (¬ (toℕ i , toℕ j) ⇿ q) ⊎ (toℕ i ∈ₚ q) → f ▷ r ≡ invalid
path-reject {_} {i} {j} {invalid}      (step pol) pᵣ≈p inv = refl
path-reject {_} {i} {j} {valid l cs p} (step pol) refl inv with (toℕ i , toℕ j) ⇿? p | toℕ i ∈ₚ? p
... | no  _    | _       = refl
... | yes _    | yes _   = refl
... | yes ij⇿p | no  i∉p with inv
...   | inj₁ ¬ij⇿d[p] = contradiction (⇿-deflate⁺ ij⇿p) ¬ij⇿d[p]
...   | inj₂ i∈d[p]   = contradiction (∈-deflate⁻ i∈d[p]) i∉p

path-accept : ∀ {n} {i j : Fin n} {r q} (f : Step i j) → path r ≡ valid q → f ▷ r ≢ invalid →
              path (f ▷ r) ≡ valid ((toℕ i , toℕ j) ∷ q)
path-accept {_} {i} {j} {invalid}      {_} (step pol) pᵣ≈q f▷r≉0 = contradiction refl f▷r≉0
path-accept {_} {i} {j} {valid l cs p} {q} (step pol) eq f▷r≉0 with (toℕ i , toℕ j) ⇿? p | toℕ i ∈ₚ? p
... | no ¬e⇿p | _       = contradiction refl f▷r≉0
... | yes _   | yes i∈p = contradiction refl f▷r≉0
... | yes e⇿p | no  i∉p with apply-result pol l cs ((toℕ i , toℕ j) ∷ p)
...   | inj₁ ≡invalid = contradiction ≡invalid f▷r≉0
...   | inj₂ (k , ds , m , l≤k , ≡valid) = begin
  path (apply pol (valid l cs ((toℕ i , toℕ j) ∷ p))) ≡⟨ cong path ≡valid ⟩
  path (valid k ds (inflate ((toℕ i , toℕ j) ∷ p) m)) ≡⟨⟩
  valid (deflate (inflate ((toℕ i , toℕ j) ∷ p) m))   ≡⟨ cong valid (deflate-inflate _ m) ⟩
  valid (deflate ((toℕ i , toℕ j) ∷ p))               ≡⟨ cong valid (deflate-skip p (inj₁ (ij⇿p⇒i≢j e⇿p))) ⟩
  valid ((toℕ i , toℕ j) ∷ deflate p)                 ≡⟨ cong (λ p → valid (_ ∷ p)) (valid-injective eq) ⟩
  valid ((toℕ i , toℕ j) ∷ q)                         ∎

isPathAlgebra : IsPathAlgebra Aₐₗₜ
isPathAlgebra = record
  { path             = path
  ; path-cong        = cong path
  ; r≈0⇒path[r]≈[]   = r≈0⇒path[r]≈[]
  ; r≈∞⇒path[r]≈∅    = r≈∞⇒path[r]≈∅
  ; path[r]≈∅⇒r≈∞    = path[r]≈∅⇒r≈∞
  ; path-reject      = path-reject
  ; path-accept      = path-accept
  }

--------------------------------------------------------------------------------
-- Aₐₗₜ simulates the algebra of BGPLite

open import RoutingLib.Routing.Algebra.Simulation
open import RoutingLib.Routing.Algebra.Comparable Aₐₗₜ

private
  ≢invalid : ∀ {k cs p} {n} {i j : Fin n} (f : Step i j) v → valid k cs p ≡ f ▷ v → f ▷ v ≢ invalid
  ≢invalid f v ᵥ≡fv fv≡ᵢ = contradiction (trans ᵥ≡fv fv≡ᵢ) λ()
  
x≡fv⇒p≢[] : ∀ {k cs p} {n} {i j : Fin n} (f : Step i j) v → valid k cs p ≡ f ▷ v → p ≢ []
x≡fv⇒p≢[] f invalid ()
x≡fv⇒p≢[] {k} {cs} {p} {n} {i} {j} f v@(valid l ds q) ≡f▷v p≡[] = contradiction (begin
  valid []                            ≡⟨ sym (cong (valid ∘ deflate) p≡[]) ⟩
  valid (deflate p)                   ≡⟨⟩
  path (valid k cs p)                 ≡⟨ cong path ≡f▷v ⟩
  path (f ▷ valid l ds q)             ≡⟨ path-accept f refl (≢invalid f v ≡f▷v) ⟩
  valid ((toℕ i , toℕ j) ∷ deflate q) ∎) λ()

x≡fv∧y≈gw⇒p≢q : ∀ {k l cs ds p q} {n} {i j m : Fin n} (f : Step i j) (g : Step i m) v w →
                valid k cs p ≡ f ▷ v → valid l ds q ≡ g ▷ w →
                j ≢ m → p ≢ q
x≡fv∧y≈gw⇒p≢q f g invalid w () _
x≡fv∧y≈gw⇒p≢q f g v invalid _ ()
x≡fv∧y≈gw⇒p≢q {p = p} {q} {i = i} {j} {m} f g v@(valid k₂ cs₂ p₂) w@(valid l₂ ds₂ q₂) ≡f▷v ≡g▷w j≢m p≡q =
  j≢m $ toℕ-injective $ ,-injectiveʳ $ ∷-injectiveˡ $ valid-injective (begin
    valid ((toℕ i , toℕ j) ∷ deflate p₂) ≡⟨ sym (path-accept f refl (≢invalid f v ≡f▷v)) ⟩
    path (f ▷ valid k₂ cs₂ p₂)           ≡⟨ sym (cong path ≡f▷v) ⟩
    valid (deflate p)                    ≡⟨ cong (valid ∘ deflate) p≡q ⟩
    valid (deflate q)                    ≡⟨ cong path ≡g▷w ⟩
    path (g ▷ valid l₂ ds₂ q₂)           ≡⟨ path-accept g refl (≢invalid g w ≡g▷w) ⟩
    valid ((toℕ i , toℕ m) ∷ deflate q₂) ∎)

≎⇒path≢ : ∀ {k l cs ds p q} → k ≡ l → valid k cs p ≎ valid l ds q → p ≢ q
≎⇒path≢ refl (0∞# refl ())
≎⇒path≢ refl (∞0# () refl)
≎⇒path≢ refl (∞∞# () ())
≎⇒path≢ refl (0e# g w refl ≈gw) = x≡fv⇒p≢[] g w ≈gw ∘ sym
≎⇒path≢ refl (e0# f v ≈fv refl) = x≡fv⇒p≢[] f v ≈fv
≎⇒path≢ refl (∞e# g w () x)
≎⇒path≢ refl (e∞# f v x ())
≎⇒path≢ refl (ee# f g v w j≢k x≈fv y≈gw) = x≡fv∧y≈gw⇒p≢q f g v w x≈fv y≈gw j≢k
  
⊕ₐₗₜ-pres-≎ : ∀ {x y z} → x ≎ y → x ≎ z → x ≎ (y ⊕ₐₗₜ z)
⊕ₐₗₜ-pres-≎ {x} {y} {z} x≎y x≎z with ⊕ₐₗₜ-sel y z
... | inj₁ y⊕z≈y = ≎-resp-≈ refl (sym y⊕z≈y) x≎y 
... | inj₂ y⊕z≈z = ≎-resp-≈ refl (sym y⊕z≈z) x≎z

⊕ₐₗₜ-sim-⊕ : ∀ {x y} → x ≎ y → x ⊕ y ≡ x ⊕ₐₗₜ y
⊕ₐₗₜ-sim-⊕ {invalid}      {invalid}      x≎y = refl
⊕ₐₗₜ-sim-⊕ {invalid}      {valid k ds q} x≎y = refl
⊕ₐₗₜ-sim-⊕ {valid l cs p} {invalid}      x≎y = refl
⊕ₐₗₜ-sim-⊕ {valid l cs p} {valid k ds q} x≎y with <-cmp l k
... | tri< _ _    _ = refl
... | tri> _ _    _ = refl
... | tri≈ _ refl _ with <-cmp (length p) (length q)
...   | tri< _ _       _ = refl
...   | tri> _ _       _ = refl
...   | tri≈ _ |p|≡|q| _ with p ≤ₗₑₓ? q | <ₗₑₓ-cmp p q
...     | yes p≤q | tri< _ _ _   = refl
...     | yes p≤q | tri> _ _ q>p = contradiction p≤q (<ₗₑₓ⇒≱ₗₑₓ q>p)
...     | yes p≤q | tri≈ _ p≡q _ = contradiction p≡q (≎⇒path≢ refl x≎y)
...     | no  p≰q | tri< p<q _ _ = contradiction (<ₗₑₓ⇒≤ₗₑₓ p<q) p≰q
...     | no  p≰q | tri> _ _ _   = refl
...     | no  p≰q | tri≈ _ p≡q _ = contradiction p≡q (≎⇒path≢ refl x≎y)

Aₐₗₜ-simulates-A : Simulates Aₐₗₜ A
Aₐₗₜ-simulates-A = record
  { to        = id
  ; from      = id
  ; to-from   = λ _ → refl
  ; toₛ       = id
  ; fromₛ     = id
  ; toₛ-fromₛ = λ _ → refl
  ; to-0#     = refl
  ; to-∞      = refl
  ; to-cong   = cong id
  ; to-▷      = λ _ _ → refl
  ; to-f∞     = refl
  ; to-⊕      = ⊕ₐₗₜ-sim-⊕
  ; ⊕-pres-≎  = ⊕ₐₗₜ-pres-≎
  }

--------------------------------------------------------------------------------
-- Aₐₗₜ is convergent

open import RoutingLib.Routing.VectorBased.Asynchronous.Convergence

Aₐₗₜ-alwaysConvergent : AlwaysConvergent Aₐₗₜ
Aₐₗₜ-alwaysConvergent = incrPaths⇒convergent isRoutingAlgebra isPathAlgebra isIncreasing
