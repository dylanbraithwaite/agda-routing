open import Data.Nat using (ℕ; zero; suc; s≤s; _+_)
open import Data.Fin using (Fin; _<_; _≤_; inject₁) renaming (zero to fzero; suc to fsuc)
open import Algebra.FunctionProperties using (Op₂)
open import Data.Vec hiding (map; zipWith)
open import Data.Product using (∃; ∃₂; _,_; _×_)
open import Data.List.Any as Any using (here; there)
open Any.Membership-≡ using () renaming (_∈_ to _∈ₗ_; _∉_ to _∉ₗ_)
open import Function using (_∘_)
open import Relation.Nullary using (yes; no)
open import Relation.Nullary.Negation using (contradiction)
open import Relation.Binary using (Decidable)
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; refl; sym)

open import RoutingLib.Data.Vec
open import RoutingLib.Data.List.SucMap using (0∉mapₛ; ∈-mapₛ; mapₛ-∈)
open import RoutingLib.Data.List.Any.GenericMembership using (∈-resp-≈)
open import RoutingLib.Data.List.All using ([]) renaming (_∷_ to _∷ₚ_)
open import RoutingLib.Data.List.All.Properties using (forced-map)
open import RoutingLib.Algebra.FunctionProperties using (_×-Preserves_)

module RoutingLib.Data.Vec.Properties where

  -----------------------
  -- To push to stdlib --
  -----------------------

  ∈-map : ∀ {a b m} {A : Set a} {B : Set b} {x : A} {xs : Vec A m} (f : A → B) → x ∈ xs → f x ∈ map f xs
  ∈-map f here          = here
  ∈-map f (there x∈xs) = there (∈-map f x∈xs)

  ∈-lookup : ∀ {a n} {A : Set a} {v : A} {xs : Vec A n} → v ∈ xs → ∃ λ i → lookup i xs ≡ v
  ∈-lookup {xs = []} ()
  ∈-lookup {xs = x ∷ xs} here = fzero , refl
  ∈-lookup {xs = x ∷ xs} (there v∈xs) with ∈-lookup v∈xs
  ... | i , xsᵢ≡v = fsuc i , xsᵢ≡v

  ∈-toList : ∀ {a n} {A : Set a} {v : A} {xs : Vec A n} → v ∈ₗ (toList xs) → v ∈ xs
  ∈-toList {xs = []}     ()
  ∈-toList {xs = x ∷ xs} (here refl)  = here
  ∈-toList {xs = x ∷ xs} (there v∈xs) = there (∈-toList v∈xs)

  lookup-map : ∀ {a b n} {A : Set a} {B : Set b} {f : A → B} (i : Fin n) (xs : Vec A n) → lookup i (map f xs) ≡ f (lookup i xs)
  lookup-map fzero (x ∷ xs) = refl
  lookup-map (fsuc i) (x ∷ xs) = lookup-map i xs

  lookup-zipWith : ∀ {a n} {A : Set a} (_•_ : Op₂ A) (i : Fin n) (xs ys : Vec A n) → lookup i (zipWith _•_ xs ys) ≡ (lookup i xs) • (lookup i ys)
  lookup-zipWith _ fzero  (x ∷ _)  (y ∷ _)    = refl
  lookup-zipWith _•_ (fsuc i) (_ ∷ xs) (_ ∷ ys)  = lookup-zipWith _•_ i xs ys

  lookup-∈ : ∀ {a n} {A : Set a} {v : A} {xs : Vec A n} {i : Fin n} → lookup i xs ≡ v → v ∈ xs
  lookup-∈ {xs = []} {i = ()}
  lookup-∈ {xs = x ∷ xs} {i = fzero} refl = here
  lookup-∈ {xs = x ∷ xs} {i = fsuc i} xsᵢ≡v = there (lookup-∈ {i = i} xsᵢ≡v)

  ----------------------
  -- Pushed to stdlib --
  ----------------------

  v[i]=x⇨lookup[i,v]≡x : ∀ {a n} {S : Set a} {x : S} {v : Vec S n} {i : Fin n}  → v [ i ]= x → lookup i v ≡ x
  v[i]=x⇨lookup[i,v]≡x here = refl
  v[i]=x⇨lookup[i,v]≡x (there xs[i]=x) = v[i]=x⇨lookup[i,v]≡x xs[i]=x


  ----------
  -- Rest --
  ----------

  map-∃-∈ : ∀ {a b n} {A : Set a} {B : Set b} {f : A → B} {v : B} (xs : Vec A n) → v ∈ map f xs → ∃ λ y → y ∈ xs × v ≡ f y
  map-∃-∈ []       ()
  map-∃-∈ (x ∷ xs) here = x , here , refl
  map-∃-∈ (x ∷ xs) (there v∈mapfxs) with map-∃-∈ xs v∈mapfxs
  ... | y , y∈xs , v≈fy = y , there y∈xs , v≈fy

  foldr-pres-P : ∀ {a p} {A : Set a} (P : A → Set p) (_⊕_ : Op₂ A) → _⊕_ ×-Preserves P → ∀ {n e} (xs : Vec A n) → (∀ i → P (lookup i xs)) → P e → P (foldr (λ _ → A) _⊕_ e xs)
  foldr-pres-P P _⊕_ ⊕-pres-p []       Pxs Pe = Pe
  foldr-pres-P P _⊕_ ⊕-pres-p (x ∷ xs) Pxs Pe = ⊕-pres-p (Pxs fzero) (foldr-pres-P P _⊕_ ⊕-pres-p xs (Pxs ∘ fsuc) Pe)

  foldr₁-pres-P : ∀ {a p} {A : Set a} (P : A → Set p) (_⊕_ : Op₂ A) → _⊕_ ×-Preserves P → ∀ {n} (xs : Vec A (suc n)) → (∀ i → P (lookup i xs)) → P (foldr₁ _⊕_ xs)
  foldr₁-pres-P _ _   _        (x ∷ [])     P-holds  = P-holds fzero
  foldr₁-pres-P P _⊕_ ⊕-pres-P (x ∷ y ∷ xs) P-holds  = ⊕-pres-P (P-holds fzero) (foldr₁-pres-P P _⊕_ ⊕-pres-P (y ∷ xs) (P-holds ∘ fsuc))

  ∉⇒List-∉ : ∀ {a} {A : Set a} {n x} {xs : Vec A n} → x ∉ xs → x ∉ₗ toList xs
  ∉⇒List-∉ {xs = []} _ ()
  ∉⇒List-∉ {xs = x ∷ xs} x∉x∷xs (here refl) = x∉x∷xs here
  ∉⇒List-∉ {xs = x ∷ xs} x∉x∷xs (there x∈xsₗ) = ∉⇒List-∉ (λ x∈xs → x∉x∷xs (there x∈xs)) x∈xsₗ

  0∉map-fsuc : ∀ {n m} (xs : Vec (Fin m) n) → fzero ∉ map fsuc xs
  0∉map-fsuc [] ()
  0∉map-fsuc (x ∷ xs) (there 0∈mapᶠxs) = 0∉map-fsuc xs 0∈mapᶠxs

  ∉-tabulate : ∀ {a n} {A : Set a} (f : Fin n → A) {v : A} → (∀ i → f i ≢ v) → v ∉ tabulate f
  ∉-tabulate {n = zero}  _ _   ()
  ∉-tabulate {n = suc n} _ v∉f here           = v∉f fzero refl
  ∉-tabulate {n = suc n} f v∉f (there v∈tabᶠ) = ∉-tabulate (f ∘ fsuc) (v∉f ∘ fsuc) v∈tabᶠ

  {-
  postulate map-∃-∈ : ∀ {a b n} {A : Set a} {B : Set b} {f : A → B} {v} {xs : Vec A n} → v ∈ map f xs → ∃ λ y → (y ∈ xs × v ≡ f y)

  postulate concat-∃-∈ : ∀ {a m n} {A : Set a} {v} {xss : Vec (Vec A m) n} → v ∈ concat xss → ∃ λ ys → (v ∈ ys × ys ∈ xss)

  concat-∃-∈ {xss = []} ()
  concat-∃-∈ {xss = [] ∷ []} ()
  concat-∃-∈ {xss = [] ∷ (xs ∷ xss)} v∈concat[xs∷xss] with concat-∃-∈ v∈concat[xs∷xss]
  ... | (ys , v∈ys , ys∈xss) = ys , v∈ys , there ys∈xss
  concat-∃-∈ {xss = (x ∷ xs) ∷ xss} here = x ∷ xs , here , here
  concat-∃-∈ {xss = (x ∷ xs) ∷ xss} (there v∈concat[xs∷xss]) with concat-∃-∈ {xss = xs ∷ xss} v∈concat[xs∷xss]
  ... | (ys , v∈ys , here) = x ∷ xs , ? , here
  ... | (ys , v∈ys , there ys∈xss) = ys , v∈ys , there ys∈xss
  -}


  --- RoutingLib operation properties

  deleteAt-∈ₗ : ∀ {a n i j} {A : Set a} (xs : Vec A (suc n)) → inject₁ j  < i → lookup j (deleteAt i xs) ≡ lookup (inject₁ j) xs
  deleteAt-∈ₗ {i = fzero}               _            ()
  deleteAt-∈ₗ {i = fsuc i} {j = fzero}  (x ∷ y ∷ xs) _         = refl
  deleteAt-∈ₗ {i = fsuc i} {j = fsuc j} (x ∷ y ∷ xs) (s≤s j<i) = deleteAt-∈ₗ (y ∷ xs) j<i

  deleteAt-∈ᵣ : ∀ {a n} {i : Fin (suc n)} {j : Fin n} {A : Set a} (xs : Vec A (suc n)) → i ≤ inject₁ j → lookup j (deleteAt i xs) ≡ lookup (fsuc j) xs
  deleteAt-∈ᵣ {i = fsuc i} {j = fzero}  (x ∷ y ∷ xs) ()
  deleteAt-∈ᵣ {i = fzero}               (x ∷ xs)      _        = refl
  deleteAt-∈ᵣ {i = fsuc i} {j = fsuc j} (x ∷ y ∷ xs) (s≤s i≤j) = deleteAt-∈ᵣ (y ∷ xs) i≤j

  findAll-hit : ∀ {a n} {A : Set a} {_≟_ : Decidable _≡_} {xs : Vec A n} {v} i → i ∈ₗ findAll _≟_ v xs → lookup i xs ≡ v
  findAll-hit {_≟_ = _≟_} {xs = x ∷ xs} {v = v} fzero i∈find with v ≟ x
  ... | yes v≡x = sym v≡x
  ... | no  v≢x = contradiction i∈find 0∉mapₛ
  findAll-hit {_≟_ = _≟_} {xs = x ∷ xs} {v = v} (fsuc i) i∈find with v ≟ x
  ... | no  v≢x = findAll-hit i (∈-mapₛ i∈find)
  ... | yes v≡x with i∈find
  ...   | here ()
  ...   | there i∈findAll = findAll-hit i (∈-mapₛ i∈findAll)

  findAll-hit₂ : ∀ {a n} {A : Set a} (_≟_ : Decidable _≡_) (xs : Vec A n) v i → lookup i xs ≡ v → i ∈ₗ findAll _≟_ v xs
  findAll-hit₂ _≟_ (x ∷ xs) v fzero v≡xs₀ with v ≟ x
  ... | yes v≡x = here refl
  ... | no  v≢x = contradiction (sym (v≡xs₀)) v≢x
  findAll-hit₂ _≟_ (x ∷ xs) v (fsuc i) v≡xsᵢ with v ≟ x
  ... | yes v≡x = there (mapₛ-∈ (findAll-hit₂ _≟_ xs v i v≡xsᵢ))
  ... | no  v≢x = mapₛ-∈ (findAll-hit₂ _≟_ xs v i v≡xsᵢ)

  findAll-miss : ∀ {a n} {A : Set a} (_≟_ : Decidable _≡_) (xs : Vec A n) v i → i ∉ₗ findAll _≟_ v xs → lookup i xs ≢ v
  findAll-miss _≟_ (x ∷ xs) v fzero i∉find with v ≟ x
  ... | no  v≢x = λ x≡v → v≢x (sym x≡v)
  ... | yes v≡x = λ _ → i∉find (here refl)
  findAll-miss _≟_ (x ∷ xs) v (fsuc i) i∉find with v ≟ x
  ... | no  v≢x = findAll-miss _≟_ xs v i (λ i∈f → i∉find (mapₛ-∈ i∈f))
  ... | yes v≡x = findAll-miss _≟_ xs v i (λ i∈f → i∉find (there (mapₛ-∈ i∈f)))


  allPairs-∃-∈ : ∀ {a} {A : Set a} {m n : ℕ} {xs : Vec A m} {ys : Vec A n} {v} → v ∈ allPairs xs ys → ∃₂ λ x y → v ≡ (x , y)
  allPairs-∃-∈ {v = (x , y)} xy∈allPairs = x , y , refl
