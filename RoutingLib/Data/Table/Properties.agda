open import Algebra.FunctionProperties using (Op₂)
open import Data.Nat using (ℕ; zero; suc; _<_; _≤_; _⊓_; _⊔_; z≤n)
open import Data.Nat.Properties using (≤-refl; ≤-trans; ⊔-sel; ⊓-sel; ⊓-mono-<; module ≤-Reasoning; +-mono-≤; +-monoˡ-<; +-monoʳ-<)
open import Data.Fin using (Fin; inject₁; inject≤) renaming (zero to fzero; suc to fsuc)
open import Data.Product using (_,_; proj₁; proj₂; ∃)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Function using (_∘_)
open import Relation.Binary
open import Relation.Binary.PropositionalEquality using (_≡_; sym; cong₂; _≢_)
  renaming (refl to ≡-refl)
open import Relation.Unary using (Pred)

open import RoutingLib.Data.Table
open import RoutingLib.Data.Table.All using (All)
open import RoutingLib.Data.Table.Any using (Any)
open import RoutingLib.Data.Table.Relation.Pointwise using (Pointwise; foldr-cong; foldr⁺-cong)
open import RoutingLib.Algebra.FunctionProperties
open import RoutingLib.Data.Nat.Properties hiding (+-monoʳ-<)
open import RoutingLib.Data.NatInf using (ℕ∞) renaming (_≤_ to _≤∞_; _⊓_ to _⊓∞_)
open import RoutingLib.Data.NatInf.Properties using () renaming (≤-refl to ≤∞-refl; ≤-antisym to ≤∞-antisym; ≤-reflexive to ≤∞-reflexive; o≤m⇒n⊓o≤m to o≤∞m⇒n⊓o≤∞m; n≤m⊎o≤m⇒n⊓o≤m to n≤∞m⊎o≤∞m⇒n⊓o≤∞m; m≤n×m≤o⇒m≤n⊓o to m≤∞n×m≤∞o⇒m≤∞n⊓o)

module RoutingLib.Data.Table.Properties where

  -- Properties of foldr

  module _ {a p} {A : Set a} (P : Pred A p) {_•_ : Op₂ A} where

    foldr-forces×ʳ : _•_ Forces-×ʳ P → ∀ e {n} (t : Table A n) →
                    P (foldr _•_ e t) → P e
    foldr-forces×ʳ forces _ {zero}  t Pe = Pe
    foldr-forces×ʳ forces e {suc n} t Pf =
      foldr-forces×ʳ forces e (t ∘ fsuc) (forces _ _ Pf)
      
    foldr-forces× : _•_ Forces-× P → ∀ e {n} (t : Table A n) →
                    P (foldr _•_ e t) → All P t
    foldr-forces× forces _ _ Pfold fzero    = proj₁ (forces _ _ Pfold)
    foldr-forces× forces _ _ Pfold (fsuc i) =
      foldr-forces× forces _ _ (proj₂ (forces _ _ Pfold)) i
    
    foldr-×pres : _•_ ×-Preserves P → ∀ {e} → P e →
                  ∀ {n} {t : Table A n} → All P t →
                  P (foldr _•_ e t)
    foldr-×pres pres Pe {zero}  PM = Pe
    foldr-×pres pres Pe {suc n} PM =
      pres (PM fzero) (foldr-×pres pres Pe (PM ∘ fsuc))

    foldr-⊎presʳ : _•_ ⊎-Preservesʳ P → ∀ {e} → P e →
                        ∀ {n} (t : Table A n) → P (foldr _•_ e t)
    foldr-⊎presʳ pres Pe {zero}  t = Pe
    foldr-⊎presʳ pres Pe {suc n} t =
      pres _ (foldr-⊎presʳ pres Pe (t ∘ fsuc))

    foldr-⊎pres : _•_ ⊎-Preserves P → ∀ e {n} {t : Table A n} →
                       Any P t → P (foldr _•_ e t)
    foldr-⊎pres pres e (fzero  , Pt₀) = pres _ _ (inj₁ Pt₀)
    foldr-⊎pres pres e (fsuc i , Ptᵢ) =
      pres _ _ (inj₂ (foldr-⊎pres pres e (i , Ptᵢ)))


  -- Properties of foldr⁺
  
  module _ {a p} {A : Set a} (P : Pred A p) {_•_ : Op₂ A} where

    foldr⁺-forces× : _•_ Forces-× P → ∀ {n} (t : Table A (suc n)) →
                    P (foldr⁺ _•_ t) → All P t
    foldr⁺-forces× forces {zero}  t Pt₀ fzero     = Pt₀
    foldr⁺-forces× forces {zero}  t Pft (fsuc ()) 
    foldr⁺-forces× forces {suc n} t Pft (fzero)   = proj₁ (forces (t fzero) _ Pft)
    foldr⁺-forces× forces {suc n} t Pft (fsuc i)  = foldr⁺-forces× forces (t ∘ fsuc) (proj₂ (forces _ _ Pft)) i
    
    foldr⁺-×pres : _•_ ×-Preserves P → ∀ {n} {t : Table A (suc n)} →
                   All P t → P (foldr⁺ _•_ t)
    foldr⁺-×pres pres {zero}  Pt = Pt fzero
    foldr⁺-×pres pres {suc n} Pt = pres (Pt _) (foldr⁺-×pres pres (Pt ∘ fsuc))
    
    foldr⁺-⊎pres : _•_ ⊎-Preserves P → ∀ {n} {t : Table A (suc n)} →
                       Any P t → P (foldr⁺ _•_ t)
    foldr⁺-⊎pres pres {zero}  (fzero , Pt₀) = Pt₀
    foldr⁺-⊎pres pres {suc n} (fzero , Pt₀) = pres _ _ (inj₁ Pt₀)
    foldr⁺-⊎pres pres {zero}  (fsuc () , _)
    foldr⁺-⊎pres pres {suc n} (fsuc i , Ptᵢ) = pres _ _ (inj₂ (foldr⁺-⊎pres pres (i , Ptᵢ)))


  min[t]<x : ∀ ⊤ {n} (t : Table ℕ n) {x} → ⊤ < x ⊎ Any (_< x) t → min ⊤ t < x
  min[t]<x ⊤ t (inj₁ ⊤<x) = foldr-⊎presʳ (_< _) o<m⇒n⊓o<m ⊤<x t
  min[t]<x ⊤ t (inj₂ t<x) = foldr-⊎pres (_< _) n<m⊎o<m⇒n⊓o<m ⊤ t<x
  
  min⁺[t]<x : ∀ {n} {t : Table ℕ (suc n)} {x} → Any (_< x) t → min⁺ t < x
  min⁺[t]<x = foldr⁺-⊎pres (_< _) n<m⊎o<m⇒n⊓o<m

  x<min⁺[t] : ∀ {n} {t : Table ℕ (suc n)} {x} → All (x <_) t → x < min⁺ t
  x<min⁺[t] = foldr⁺-×pres (_ <_) m<n×m<o⇒m<n⊓o
  
  min[s]<min[t] : ∀ ⊤₁ {⊤₂} {m n} {s : Table ℕ m} {t : Table ℕ n} → ⊤₁ < ⊤₂ ⊎ Any (_< ⊤₂) s →
                  All (λ y → ⊤₁ < y ⊎ Any (_< y) s) t → min ⊤₁ s < min ⊤₂ t
  min[s]<min[t] ⊤₁ {n = zero}  v all = min[t]<x ⊤₁ _ v
  min[s]<min[t] ⊤₁ {n = suc m} v all = m<n×m<o⇒m<n⊓o
    (min[t]<x ⊤₁ _ (all fzero))
    (min[s]<min[t] ⊤₁ v (all ∘ fsuc))

  min⁺[s]<min⁺[t] : ∀ {m n} {s : Table ℕ (suc m)} {t : Table ℕ (suc n)} →
                   All (λ y → Any (_< y) s) t → min⁺ s < min⁺ t
  min⁺[s]<min⁺[t] {n = zero}  {s} {t} all = min⁺[t]<x (all fzero)
  min⁺[s]<min⁺[t] {n = suc n} {s} {t} all = m<n×m<o⇒m<n⊓o (min⁺[t]<x (all fzero)) (min⁺[s]<min⁺[t] (all ∘ fsuc))


  max[t]≤x : ∀ {n} {t : Table ℕ n} {x ⊥} → All (_≤ x) t → ⊥ ≤ x → max ⊥ t ≤ x
  max[t]≤x {x = x} xs≤x ⊥≤x = foldr-×pres (_≤ x) n≤m×o≤m⇒n⊔o≤m ⊥≤x xs≤x

  postulate max[t]<x : ∀ {n} {t : Table ℕ n} {x ⊥} → All (_< x) t → ⊥ < x → max ⊥ t < x
  
  x≤max[t] : ∀ {n x} {t : Table ℕ n} ⊥ → x ≤ ⊥ ⊎ Any (x ≤_) t → x ≤ max ⊥ t
  x≤max[t] {n} {x} {t} ⊥ (inj₁ x≤⊥) = foldr-⊎presʳ (_ ≤_) m≤o⇒m≤n⊔o x≤⊥ t
  x≤max[t] ⊥ (inj₂ x≤t) = foldr-⊎pres (_ ≤_) m≤n⊎m≤o⇒m≤n⊔o ⊥ x≤t




  postulate max-cong : ∀ {n} {⊥₁ ⊥₂} → ⊥₁ ≡ ⊥₂ → {t s : Table ℕ n} →
             Pointwise _≡_ t s → max ⊥₁ t ≡ max ⊥₂ s
  --max-cong eq eq₂ = foldr-cong (cong₂ _⊔_) eq eq₂

  postulate max⁺-cong : ∀ {n} {t s : Table ℕ (suc n)} → Pointwise _≡_ t s → max⁺ t ≡ max⁺ s

  postulate t≤max⁺[t] : ∀ {n} (t : Table ℕ (suc n)) → All (_≤ max⁺ t) t

  postulate max⁺[t]≤x : ∀ {n} {t : Table ℕ (suc n)} {x} → All (_≤ x) t → max⁺ t ≤ x
  
  postulate max-constant : ∀ {n} {⊥} {t : Table ℕ n} →
                 ∀ {x} → ⊥ ≡ x → All (_≡ x) t → max ⊥ t ≡ x
  --max-constant {x = x} = foldr-×pres (_≡ x) ⊔-preserves-≡x
  
  ⊥≤max[t] : ∀ {n} ⊥ (t : Table ℕ n)→ ⊥ ≤ max ⊥ t
  ⊥≤max[t] {n} ⊥ t = x≤max[t] {n} ⊥ (inj₁ ≤-refl)

  t≤max[t] : ∀ {n} ⊥ (t : Table ℕ n) → All (_≤ max ⊥ t) t
  t≤max[t] ⊥ t i = x≤max[t] ⊥ (inj₂ (i , ≤-refl))

  x<max[t] : ∀ {n x} {t : Table ℕ n} ⊥ → x < ⊥ ⊎ Any (x <_) t → x < max ⊥ t
  x<max[t] {n} {x} {t} ⊥ (inj₁ x<⊥) = foldr-⊎presʳ (_ <_) m≤o⇒m≤n⊔o x<⊥ t
  x<max[t] ⊥ (inj₂ x<t) = foldr-⊎pres (_ <_) m≤n⊎m≤o⇒m≤n⊔o ⊥ x<t

  max[s]≤max[t] : ∀ ⊥₁ {⊥₂} {m n} {s : Table ℕ m} {t : Table ℕ n} → ⊥₁ ≤ ⊥₂ ⊎ Any (⊥₁ ≤_) t →
                  All (λ y → y ≤ ⊥₂ ⊎ Any (y ≤_) t) s → max ⊥₁ s ≤ max ⊥₂ t
  max[s]≤max[t] ⊥₁ {⊥₂} {m = zero}  v all = x≤max[t] ⊥₂ v
  max[s]≤max[t] ⊥₁ {⊥₂} {m = suc n} {s = s} {t = t}  v all = n≤m×o≤m⇒n⊔o≤m
                (x≤max[t] ⊥₂ (all fzero))
                (max[s]≤max[t] ⊥₁ v (all ∘ fsuc))

  min∞[t]≤x : ∀ ⊤ {n} (t : Table ℕ∞ n) {x} → ⊤ ≤∞ x ⊎ Any (_≤∞ x) t → min∞ ⊤ t ≤∞ x
  min∞[t]≤x ⊤ t (inj₁ ⊤≤x) = foldr-⊎presʳ (_≤∞ _)  o≤∞m⇒n⊓o≤∞m ⊤≤x t
  min∞[t]≤x ⊤ t (inj₂ t≤x) = foldr-⊎pres (_≤∞ _) n≤∞m⊎o≤∞m⇒n⊓o≤∞m ⊤ t≤x

  min∞[s]≤min∞[t] : ∀ ⊤₁ {⊤₂} {m n} {s : Table ℕ∞ m} {t : Table ℕ∞ n} → ⊤₁ ≤∞ ⊤₂ ⊎ Any (_≤∞ ⊤₂) s → All (λ y → ⊤₁ ≤∞ y ⊎ Any (_≤∞ y) s) t → min∞ ⊤₁ s ≤∞ min∞ ⊤₂ t
  min∞[s]≤min∞[t] ⊤₁ {n = zero}  v all = min∞[t]≤x ⊤₁ _ v
  min∞[s]≤min∞[t] ⊤₁ {n = suc m} v all = m≤∞n×m≤∞o⇒m≤∞n⊓o
                  (min∞[t]≤x ⊤₁ _ (all fzero))
                  (min∞[s]≤min∞[t] ⊤₁ v (all ∘ fsuc))

  x≤min∞[t] : ∀ {n x ⊤} {t : Table ℕ∞ n} → All (x ≤∞_) t → x ≤∞ ⊤ → x ≤∞ min∞ ⊤ t
  x≤min∞[t] {n} {x} {⊤} {t} all x≤⊤ = foldr-×pres (x ≤∞_) m≤∞n×m≤∞o⇒m≤∞n⊓o x≤⊤ all 

  min∞[t]≡x : ∀ {n x ⊤} {t : Table ℕ∞ n} → Any (x ≡_) t → All (x ≤∞_) t → x ≤∞ ⊤ → min∞ ⊤ t ≡ x
  min∞[t]≡x {n} {x} {⊤} {t} (i , x≡tᵢ) all x≤⊤ = ≤∞-antisym
            (min∞[t]≤x ⊤ t (inj₂ (i , ≤∞-reflexive (sym x≡tᵢ))))
            (x≤min∞[t] all x≤⊤)

  -- Properties of sum
  sum[s]≤sum[t] : ∀ {n} {s t : Table ℕ n} → Pointwise _≤_ s t → sum s ≤ sum t
  sum[s]≤sum[t] {zero} {s} {t} s≤t = z≤n
  sum[s]≤sum[t] {suc n} {s} {t} s≤t = +-mono-≤ (s≤t fzero) (sum[s]≤sum[t] {n} (λ i → s≤t (fsuc i)))
  
  sum[s]<sum[t] : ∀ {n} {s t : Table ℕ n} → Pointwise _≤_ s t →
                  (∃ λ i → s i < t i) → sum s < sum t
  sum[s]<sum[t] {zero} {s} {t} _ (() , _)
  sum[s]<sum[t] {suc n} {s} {t} s≤t (fzero , sᵢ<tᵢ)  = +-monoˡ-< sᵢ<tᵢ (sum[s]≤sum[t] {n} (λ i → s≤t (fsuc i))) 
  sum[s]<sum[t] {suc n} {s} {t} s≤t (fsuc i , sᵢ<tᵢ) = +-monoʳ-< (s≤t fzero)
                (sum[s]<sum[t] (λ j → s≤t (fsuc j)) (i , sᵢ<tᵢ))

