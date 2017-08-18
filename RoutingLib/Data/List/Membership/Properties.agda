open import Level using (_⊔_)
open import Relation.Binary using (Setoid; Rel; Symmetric; _Respects_; _Preserves_⟶_; _Preserves₂_⟶_⟶_) renaming (Decidable to Decidable₂)
open import Relation.Binary.PropositionalEquality using (refl; _≡_; _≢_; cong; subst; subst₂; inspect; [_]) renaming (trans to ≡-trans; sym to ≡-sym; setoid to ≡-setoid)
open import Relation.Binary.List.Pointwise using ([]; _∷_) renaming (setoid to list-setoid)
open import Relation.Nullary.Negation using (contradiction)
open import Relation.Nullary using (¬_; yes; no)
open import Function using (_∘_; id)
open import Data.List.All using (All; _∷_; [])
open import Data.Nat using (_≤_; _<_; zero; suc; s≤s; z≤n)
open import Data.Fin using (Fin) renaming (zero to fzero; suc to fsuc)
open import Data.Maybe using (nothing; just; Maybe; Eq; drop-just)
open import Data.Empty using (⊥-elim)
open import Data.List hiding (any)
open import Data.List.Any using (here; there; any) renaming (map to mapₐ)
open import Data.Vec using (Vec; toList; fromList) renaming (_∈_ to _∈ᵥ_; here to hereᵥ; there to thereᵥ)
open import Data.Product using (∃; ∃₂; _×_; _,_; swap) renaming (map to mapₚ)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Data.Bool using (true; false; if_then_else_)
open import Relation.Unary using (Decidable; _⇒_) renaming (_⊆_ to _⋐_)
open import Algebra.FunctionProperties using (Op₂; RightIdentity; Selective)

open import RoutingLib.Data.List
open import RoutingLib.Data.Maybe.Base
open import RoutingLib.Data.Maybe.Properties using (just-injective) renaming (reflexive to eq-reflexive; sym to eq-sym; trans to eq-trans)
import RoutingLib.Data.List.Membership as Membership
open import RoutingLib.Data.Nat.Properties using (suc-injective)
open import RoutingLib.Data.List.Any.Properties
open import RoutingLib.Data.List.Permutation using (_⇿_; _◂_≡_; _∷_; []; here; there)
open import RoutingLib.Data.List.Uniqueness using (Unique; _∷_)
open import RoutingLib.Data.List.All using ([]; _∷_)
open import RoutingLib.Data.List.All.Properties using (All¬⇒¬Any)


module RoutingLib.Data.List.Membership.Properties where

  -----------------------------------
  -- Properties involving 1 setoid --
  -----------------------------------

  module SingleSetoid {c ℓ} (S : Setoid c ℓ) where

    open Setoid S renaming (Carrier to A; refl to ≈-refl)
    open Setoid (list-setoid S) using () renaming (_≈_ to _≈ₗ_; sym to symₗ; refl to reflₗ)

    open Membership S using (_∈_; _∉_; _⊆_; indexOf; deduplicate)
    open Membership (list-setoid S) using () renaming (_∈_ to _∈ₗ_)

    ∈-dec : Decidable₂ _≈_ → Decidable₂ _∈_
    ∈-dec _≟_ x [] = no λ()
    ∈-dec _≟_ x (y ∷ ys) with x ≟ y | ∈-dec _≟_ x ys
    ... | yes x≈y | _        = yes (here x≈y)
    ... | _       | yes x∈ys = yes (there x∈ys)
    ... | no  x≉y | no  x∉ys = no (λ {(here x≈y) → x≉y x≈y; (there x∈ys) → x∉ys x∈ys})

    ∈-resp-≈ : ∀ {v w xs} → v ∈ xs → v ≈ w → w ∈ xs
    ∈-resp-≈ (here v≈x) v≈w = here (trans (sym v≈w) v≈x)
    ∈-resp-≈ (there v∈xs) v≈w = there (∈-resp-≈ v∈xs v≈w)

    ∉-resp-≈ : ∀ {v w xs} → v ∉ xs → v ≈ w → w ∉ xs
    ∉-resp-≈ v∉xs v≈w w∈xs = v∉xs (∈-resp-≈ w∈xs (sym v≈w))

    ∈-resp-≈ₗ : ∀ {v xs ys} → v ∈ xs → xs ≈ₗ ys → v ∈ ys
    ∈-resp-≈ₗ (here v≈x) (x≈y ∷ _) = here (trans v≈x x≈y)
    ∈-resp-≈ₗ (there v∈xs) (_ ∷ xs≈ys) = there (∈-resp-≈ₗ v∈xs xs≈ys)

    ∉-resp-≈ₗ : ∀ {v xs ys} → v ∉ xs → xs ≈ₗ ys → v ∉ ys
    ∉-resp-≈ₗ v∉xs xs≈ys v∈ys = v∉xs (∈-resp-≈ₗ v∈ys (symₗ xs≈ys))

    -- ++ operation

    -- stdlib
    ∈-++⁺ʳ : ∀ {v} xs {ys} → v ∈ ys → v ∈ xs ++ ys
    ∈-++⁺ʳ = Any-++⁺ʳ

    -- stdlib
    ∈-++⁺ˡ : ∀ {v xs ys} → v ∈ xs → v ∈ xs ++ ys
    ∈-++⁺ˡ = Any-++⁺ˡ

    -- stdlib
    ∈-++⁻ : ∀ {v} xs {ys} → v ∈ xs ++ ys → v ∈ xs ⊎ v ∈ ys
    ∈-++⁻ = Any-++⁻

    -- concat

    ∈-concat⁺ : ∀ {v xs xss} → v ∈ xs → xs ∈ₗ xss → v ∈ concat xss
    ∈-concat⁺ {_} {_ ∷ _} {[] ∷ _}         (here _)     (here ())
    ∈-concat⁺ {_} {_ ∷ _} {[] ∷ _}         (there _)    (here ())
    ∈-concat⁺ {_} {_ ∷ _} {(_ ∷ _) ∷ _}    (here v≈x)   (here (x≈y ∷ _))   = here (trans v≈x x≈y)
    ∈-concat⁺ {_} {_ ∷ _} {(y ∷ ys) ∷ xss} (there v∈xs) (here (_ ∷ xs≈ys)) = there (∈-concat⁺ {xss = ys ∷ xss} v∈xs (here xs≈ys))
    ∈-concat⁺ {_} {_ ∷ _} {ys ∷ xss}       v∈xs         (there s)          = ∈-++⁺ʳ ys (∈-concat⁺ v∈xs (s))

    ∈-concat⁻ : ∀ {v xss} → v ∈ concat xss → ∃ λ ys → v ∈ ys × ys ∈ₗ xss
    ∈-concat⁻ {_} {[]} ()
    ∈-concat⁻ {_} {[] ∷ []} ()
    ∈-concat⁻ {_} {[] ∷ (xs ∷ xss)} v∈concat[xs∷xss] with ∈-concat⁻ v∈concat[xs∷xss]
    ... | (ys , v∈ys , ys∈xss) = ys , v∈ys , there ys∈xss
    ∈-concat⁻ {_} {(x ∷ xs) ∷ xss} (here v≈x) = x ∷ xs , here v≈x , here reflₗ
    ∈-concat⁻ {_} {(x ∷ xs) ∷ xss} (there v∈concat[xs∷xss]) with ∈-concat⁻ {xss = xs ∷ xss} v∈concat[xs∷xss]
    ... | (ys , v∈ys , here ys≈xs)   = x ∷ xs , ∈-resp-≈ₗ (there v∈ys) (≈-refl ∷ ys≈xs) , here reflₗ
    ... | (ys , v∈ys , there ys∈xss) = ys , v∈ys , there ys∈xss


    -- tabulate

    ∈-tabulate⁺ : ∀ {n} (f : Fin n → A) i → f i ∈ tabulate f
    ∈-tabulate⁺ f i = Any-tabulate⁺ i ≈-refl
    
    ∈-tabulate⁻ : ∀ {n} {f : Fin n → A} {x} → x ∈ tabulate f → ∃ λ i → x ≈ f i
    ∈-tabulate⁻ = Any-tabulate⁻
    

    -- applyUpTo

    ∈-applyUpTo⁺ : ∀ f {n i} → i < n → f i ∈ applyUpTo f n
    ∈-applyUpTo⁺ f (s≤s z≤n)       = here ≈-refl
    ∈-applyUpTo⁺ f (s≤s (s≤s i≤n)) = there (∈-applyUpTo⁺ (f ∘ suc) (s≤s i≤n))

    ∈-applyBetween⁺ : ∀ f {s e i} → s ≤ i → i < e → f i ∈ applyBetween f s e
    ∈-applyBetween⁺ f s≤i i<e = Any-applyBetween⁺ f s≤i i<e ≈-refl
    
    ∈-applyBetween⁻ : ∀ f s e {v} → v ∈ applyBetween f s e → ∃ λ i → s ≤ i × i < e × v ≈ f i
    ∈-applyBetween⁻ f s e v∈ = Any-applyBetween⁻ f s e v∈
    

    -- dfilter

    ∈-dfilter⁺ : ∀ {p} {P : A → Set p} (P? : Decidable P) → P Respects _≈_ →
                 ∀ {v} → P v → ∀ {xs} → v ∈ xs → v ∈ dfilter P? xs
    ∈-dfilter⁺ P? resp Pv {x ∷ _} (here v≈x)   with P? x
    ... | yes _   = here v≈x
    ... | no  ¬Px = contradiction (resp v≈x Pv) ¬Px
    ∈-dfilter⁺ P? resp Pv {x ∷ _} (there v∈xs) with P? x
    ... | yes _ = there (∈-dfilter⁺ P? resp Pv v∈xs)
    ... | no  _ = ∈-dfilter⁺ P? resp Pv v∈xs

    ∈-dfilter⁻ : ∀ {p} {P : A → Set p} (P? : Decidable P) → P Respects _≈_ →
                 ∀ {v xs} → v ∈ dfilter P? xs → v ∈ xs × P v
    ∈-dfilter⁻ P? resp {v} {[]}     ()
    ∈-dfilter⁻ P? resp {v} {x ∷ xs} v∈dfilter with P? x | v∈dfilter
    ... | no  _  | v∈df       = mapₚ there id (∈-dfilter⁻ P? resp v∈df)
    ... | yes Px | here  v≈x  = here v≈x , resp (sym v≈x) Px
    ... | yes Px | there v∈df = mapₚ there id (∈-dfilter⁻ P? resp v∈df)

    ∉-dfilter₁ : ∀ {p} {P : A → Set p} (P? : Decidable P) {v} {xs} → v ∉ xs → v ∉ dfilter P? xs
    ∉-dfilter₁ P? {_} {[]}     _      ()
    ∉-dfilter₁ P? {v} {x ∷ xs} v∉x∷xs v∈f[x∷xs] with P? x | v∈f[x∷xs]
    ... | no  _ | v∈f[xs]       = ∉-dfilter₁ P? (v∉x∷xs ∘ there) v∈f[xs]
    ... | yes _ | here  v≈x     = v∉x∷xs (here v≈x)
    ... | yes _ | there v∈f[xs] = ∉-dfilter₁ P? (v∉x∷xs ∘ there) v∈f[xs]

    ∉-dfilter₂ : ∀ {p} {P : A → Set p} (P? : Decidable P) → P Respects _≈_ → ∀ {v} → ¬ P v → ∀ xs → v ∉ dfilter P? xs
    ∉-dfilter₂ P? resp ¬Pv [] ()
    ∉-dfilter₂ P? resp ¬Pv (x ∷ xs) v∈f[x∷xs] with P? x | v∈f[x∷xs]
    ... | no  _  | v∈f[xs]       = ∉-dfilter₂ P? resp ¬Pv xs v∈f[xs]
    ... | yes Px | here  v≈x     = ¬Pv (resp (sym v≈x) Px)
    ... | yes _  | there v∈f[xs] = ∉-dfilter₂ P? resp ¬Pv xs v∈f[xs]

    
    ⊆-dfilter : ∀ {p} {P : A → Set p} (P? : Decidable P)
                  {q} {Q : A → Set q} (Q? : Decidable Q) → 
                  P ⋐ Q → 
                  ∀ xs → dfilter P? xs ⊆ dfilter Q? xs
    ⊆-dfilter P? Q? P⋐Q [] ()
    ⊆-dfilter P? Q? P⋐Q (x ∷ xs) v∈f[x∷xs] with P? x | Q? x
    ... | no  _  | no  _  = ⊆-dfilter P? Q? P⋐Q xs v∈f[x∷xs]
    ... | yes Px | no ¬Qx = contradiction (P⋐Q Px) ¬Qx
    ... | no  _  | yes _  = there (⊆-dfilter P? Q? P⋐Q xs v∈f[x∷xs])
    ... | yes _  | yes _  with v∈f[x∷xs]
    ...   | here  v≈x     = here v≈x
    ...   | there v∈f[xs] = there (⊆-dfilter P? Q? P⋐Q xs v∈f[xs])

    foldr-∈ : ∀ {_•_} → Selective _≈_ _•_ → ∀ e xs → foldr _•_ e xs ≈ e ⊎ foldr _•_ e xs ∈ xs 
    foldr-∈ {_}   •-sel i [] = inj₁ ≈-refl
    foldr-∈ {_•_} •-sel i (x ∷ xs) with •-sel x (foldr _•_ i xs)
    ... | inj₁ x•f≈x = inj₂ (here x•f≈x)
    ... | inj₂ x•f≈f with foldr-∈ •-sel i xs
    ...   | inj₁ f≈i  = inj₁ (trans x•f≈f f≈i)
    ...   | inj₂ f∈xs = inj₂ (∈-resp-≈ (there f∈xs) (sym x•f≈f))

    -- deduplicate

    ∈-deduplicate⁺ : ∀ _≟_ {x xs} → x ∈ xs → x ∈ deduplicate _≟_ xs
    ∈-deduplicate⁺ _≟_ {y} {x ∷ xs} (here y≈x)   with any (x ≟_) xs
    ... | yes x∈xs = ∈-deduplicate⁺ _≟_ (∈-resp-≈ x∈xs (sym y≈x))
    ... | no  _    = here y≈x
    ∈-deduplicate⁺ _≟_ {y} {x ∷ xs} (there y∈xs) with any (x ≟_) xs
    ... | yes _ = ∈-deduplicate⁺ _≟_ y∈xs
    ... | no  _ = there (∈-deduplicate⁺ _≟_ y∈xs)

    ∈-deduplicate⁻ : ∀ _≟_ {x xs} → x ∈ deduplicate _≟_ xs → x ∈ xs
    ∈-deduplicate⁻ _≟_ {y} {[]} ()
    ∈-deduplicate⁻ _≟_ {y} {x ∷ xs} x∈dedup with any (x ≟_) xs | x∈dedup
    ... | yes _ | x∈dedup[xs]       = there (∈-deduplicate⁻ _≟_ x∈dedup[xs])
    ... | no  _ | here y≈x          = here y≈x
    ... | no  _ | there y∈dedup[xs] = there (∈-deduplicate⁻ _≟_ y∈dedup[xs])
    
    ∈-perm : ∀ {x xs ys} → x ∈ xs → xs ⇿ ys → x ∈ ys
    ∈-perm = Any-⇿

    ∈-length : ∀ {x xs} → x ∈ xs → ∃ λ n → length xs ≡ suc n
    ∈-length {_} {_ ∷ xs} (here px)    = length xs , refl
    ∈-length {_} {_ ∷ _}  (there x∈xs) = mapₚ suc (cong suc) (∈-length x∈xs)

    ∈-index : ∀ {i xs} (i<|xs| : i < length xs) → index xs i<|xs| ∈ xs
    ∈-index {_}     {[]}     ()
    ∈-index {zero}  {x ∷ xs} (s≤s z≤n)    = here ≈-refl
    ∈-index {suc i} {x ∷ xs} (s≤s i<|xs|) = there (∈-index i<|xs|)


    indexOf[xs]≤|xs| : ∀ {x xs} (x∈xs : x ∈ xs) → indexOf x∈xs ≤ length xs
    indexOf[xs]≤|xs| (here px)    = z≤n
    indexOf[xs]≤|xs| (there x∈xs) = s≤s (indexOf[xs]≤|xs| x∈xs)

    indexOf-cong : ∀ {x y xs} → x ≈ y → (x∈xs : x ∈ xs) (y∈xs : y ∈ xs) → Unique S xs → indexOf x∈xs ≡ indexOf y∈xs
    indexOf-cong x≈y (here x≈z)   (here y≈z)   _            = refl
    indexOf-cong x≈y (here x≈z)   (there y∈xs) (z≉xs ∷ xs!) = contradiction (∈-resp-≈ y∈xs (trans (sym x≈y) x≈z)) (All¬⇒¬Any z≉xs)
    indexOf-cong x≈y (there x∈xs) (here y≈z)   (z≉xs ∷ xs!) = contradiction (∈-resp-≈ x∈xs (trans x≈y y≈z)) (All¬⇒¬Any z≉xs)
    indexOf-cong x≈y (there x∈xs) (there y∈xs) (_ ∷ xs!)    = cong suc (indexOf-cong x≈y x∈xs y∈xs xs!)

    indexOf-revCong : ∀ {x y xs} (x∈xs : x ∈ xs) (y∈xs : y ∈ xs) → indexOf x∈xs ≡ indexOf y∈xs → x ≈ y
    indexOf-revCong (here x≈z)   (here y≈z)   refl    = trans x≈z (sym y≈z)
    indexOf-revCong (here x≈z)   (there y∈xs) ()
    indexOf-revCong (there x∈xs) (here y≈z)   ()
    indexOf-revCong (there x∈xs) (there y∈xs) indexEq = indexOf-revCong x∈xs y∈xs (suc-injective indexEq)

    indexOf-index : ∀ {i xs} → Unique S xs → (i<|xs| : i < length xs) (xsᵢ∈xs : (index xs i<|xs|) ∈ xs) → indexOf xsᵢ∈xs ≡ i
    indexOf-index {_}     []           ()     
    indexOf-index {zero}  (_    ∷ _)   (s≤s i<|xs|) (here xsᵢ≈x)   = refl
    indexOf-index {zero}  (x≉xs ∷ _)   (s≤s i<|xs|) (there x∈xs)  = contradiction x∈xs (All¬⇒¬Any x≉xs)
    indexOf-index {suc i} (x≉xs ∷ _)   (s≤s i<|xs|) (here xsᵢ≈x)   = contradiction (∈-resp-≈ (∈-index i<|xs|) xsᵢ≈x) (All¬⇒¬Any x≉xs)
    indexOf-index {suc i} (_    ∷ xs!) (s≤s i<|xs|) (there xsᵢ∈xs) = cong suc (indexOf-index xs! i<|xs| xsᵢ∈xs)

  open SingleSetoid public
    
    
  {-
    ∈-filter : ∀ {P} → (∀ {x y} → x ≈ y → P x ≡ P y) → ∀ {v xs} → v ∈ xs → P v ≡ true → v ∈ filter P xs
    ∈-filter {P} P-resp-≈ {v} {xs} v∈xs Pv = ∈-gfilter setoid (λ v → if (P v) then just v else nothing) v∈xs test resp
      where

      test : Eq _≈_ (if P v then just v else nothing) (just v)
      test rewrite Pv = just ≈-refl

      resp : ∀ {x y} → x ≈ y → Eq _≈_ (if P x then just x else nothing) (if P y then just y else nothing)
      resp {x} {y} x≈y rewrite (P-resp-≈ x≈y) with P y
      ... | false = nothing
      ... | true  = just x≈y

    ∉-filter₁ : ∀ P {v xs} → v ∉ xs → v ∉ filter P xs
    ∉-filter₁ P {v} {[]} _ ()
    ∉-filter₁ P {v} {x ∷ xs} v∉x∷xs with predBoolToMaybe P x | inspect (predBoolToMaybe P) x
    ... | nothing | _ = ∉-filter₁ P (v∉x∷xs ∘ there)
    ... | just y  | [ t ] with P x
    ...   | true  = λ {(here v≈y) → (v∉x∷xs ∘ here) (trans v≈y (sym (reflexive (just-injective t)))); (there v∈fxs) → (∉-filter₁ P (v∉x∷xs ∘ there)) v∈fxs}
    ...   | false = contradiction t λ()

    ∉-filter₂ : ∀ {P} → (∀ {x y} → x ≈ y → P x ≡ P y) → ∀ {v} → P v ≡ false → ∀ xs → v ∉ filter P xs
    ∉-filter₂ {_} P-resp-≈ ¬Pv [] ()
    ∉-filter₂ {P} P-resp-≈ ¬Pv (x ∷ xs) v∈fₚx∷xs with P x | inspect P x
    ... | false | _ = ∉-filter₂ P-resp-≈ ¬Pv xs v∈fₚx∷xs
    ... | true  | [ Px ] with v∈fₚx∷xs
    ...   | here  v≈x    = contradiction (≡-trans (≡-trans (≡-sym Px) (P-resp-≈ (sym v≈x))) ¬Pv) λ()
    ...   | there v∈fₚxs = ∉-filter₂ P-resp-≈ ¬Pv xs v∈fₚxs

    gfilter-∈ : ∀ P {v} xs → v ∈ gfilter P xs → ∃ λ w → w ∈ xs × Eq _≈_ (P w) (just v)
    gfilter-∈ P [] ()
    gfilter-∈ P (x ∷ xs) _ with P x | inspect P x
    gfilter-∈ P (x ∷ xs) v∈fₚxs         | nothing | _ with gfilter-∈ P xs v∈fₚxs
    ... | (w , w∈xs , Pw≈justᵥ) = w , there w∈xs , Pw≈justᵥ
    gfilter-∈ P (x ∷ xs) (here v≈w)     | just w  | [ Px≡justw ] = x , (here ≈-refl) , eq-trans trans (eq-reflexive ≈-refl Px≡justw) (just (sym v≈w))
    gfilter-∈ P (x ∷ xs) (there v∈fₚxs) | just _  | _ with gfilter-∈ P xs v∈fₚxs
    ... | (w , w∈xs , Pw≈justᵥ) = w , there w∈xs , Pw≈justᵥ
  -}



  ------------------------------------
  -- Properties involving 2 setoids --
  ------------------------------------

  module DoubleSetoid {c₁ c₂ ℓ₁ ℓ₂} (S₁ : Setoid c₁ ℓ₁) (S₂ : Setoid c₂ ℓ₂) where

    open Setoid S₁ using () renaming (Carrier to A; _≈_ to _≈₁_; refl to refl₁; sym to sym₁; trans to trans₁)
    open Setoid S₂ using () renaming (Carrier to B; _≈_ to _≈₂_; refl to refl₂; sym to sym₂; trans to trans₂)
    open Membership S₁ using () renaming (_∈_ to _∈₁_)
    open Membership S₂ using () renaming (_∈_ to _∈₂_)

    ∈-map⁺ : ∀ {f} → f Preserves _≈₁_ ⟶ _≈₂_ → ∀ {v xs} → v ∈₁ xs → f v ∈₂ map f xs
    ∈-map⁺ f-pres v∈xs = Any-map⁺ (mapₐ f-pres v∈xs)

    ∈-map⁻ : ∀ {f v xs} → v ∈₂ map f xs → ∃ λ a → a ∈₁ xs × v ≈₂ f a
    ∈-map⁻ {xs = []}     ()
    ∈-map⁻ {xs = x ∷ xs} (here v≈fx) = x , here refl₁ , v≈fx
    ∈-map⁻ {xs = x ∷ xs} (there v∈mapfxs) with ∈-map⁻ v∈mapfxs
    ... | a , a∈xs , v≈fa = a , there a∈xs , v≈fa

    ∈-gfilter : ∀ P {v xs a} → v ∈₁ xs → Eq _≈₂_ (P v) (just a) → (∀ {x y} → x ≈₁ y → Eq _≈₂_ (P x) (P y)) → a ∈₂ gfilter P xs
    ∈-gfilter _ {_} {[]}     ()
    ∈-gfilter P {v} {x ∷ xs} v∈xs Pᵥ≈justₐ P-resp-≈ with P x | inspect P x | v∈xs
    ... | nothing | [ Px≡nothing ] | here v≈x    = contradiction (eq-trans trans₂ (eq-trans trans₂ (eq-reflexive refl₂ (≡-sym Px≡nothing)) (P-resp-≈ (sym₁ v≈x))) Pᵥ≈justₐ) λ()
    ... | nothing | [ _ ]          | there v∈xs₂ = ∈-gfilter P v∈xs₂ Pᵥ≈justₐ P-resp-≈
    ... | just b  | [ Px≡justb ]   | here v≈x    = here (drop-just (eq-trans trans₂ (eq-trans trans₂ (eq-sym sym₂ Pᵥ≈justₐ) (P-resp-≈ v≈x)) (eq-reflexive refl₂ Px≡justb)))
    ... | just b  | _              | there v∈xs₂ = there (∈-gfilter P v∈xs₂ Pᵥ≈justₐ P-resp-≈)


  open DoubleSetoid public


  ------------------------------------
  -- Properties involving 3 setoids --
  ------------------------------------

  module TripleSetoid {c₁ c₂ c₃ ℓ₁ ℓ₂ ℓ₃} (S₁ : Setoid c₁ ℓ₁) (S₂ : Setoid c₂ ℓ₂) (S₃ : Setoid c₃ ℓ₃) where

    open Setoid S₁ using () renaming (Carrier to A; _≈_ to _≈₁_; refl to refl₁; sym to sym₁; trans to trans₁)
    open Setoid S₂ using () renaming (Carrier to B; _≈_ to _≈₂_; refl to refl₂; sym to sym₂; trans to trans₂)
    open Setoid S₃ using () renaming (Carrier to C; _≈_ to _≈₃_; refl to refl₃; sym to sym₃; trans to trans₃)
    open Membership S₁ using () renaming (_∈_ to _∈₁_)
    open Membership S₂ using () renaming (_∈_ to _∈₂_)
    open Membership S₃ using () renaming (_∈_ to _∈₃_)

    -- combine

    ∈-combine : ∀ {f} → f Preserves₂ _≈₁_ ⟶ _≈₂_ ⟶ _≈₃_ → ∀ {xs ys a b} → a ∈₁ xs → b ∈₂ ys → f a b ∈₃ combine f xs ys
    ∈-combine pres {_ ∷ _} {ys} (here  a≈x)  b∈ys = ∈-resp-≈ S₃ (∈-++⁺ˡ S₃ (∈-map⁺ S₂ S₃ (pres refl₁) b∈ys)) (pres (sym₁ a≈x) refl₂)
    ∈-combine pres {_ ∷ _} {ys} (there a∈xs) b∈ys = ∈-++⁺ʳ S₃ (map _ ys) (∈-combine pres a∈xs b∈ys)

    combine-∈ : ∀ f xs ys {v} → v ∈₃ combine f xs ys → ∃₂ λ a b → a ∈₁ xs × b ∈₂ ys × v ≈₃ f a b
    combine-∈ f [] ys ()
    combine-∈ f (x ∷ xs) ys v∈map++com with ∈-++⁻ S₃ (map (f x) ys) v∈map++com
    combine-∈ f (x ∷ xs) ys v∈map++com | inj₁ v∈map with ∈-map⁻ S₂ S₃ v∈map
    ... | (b , b∈ys , v≈fxb) = x , b , here refl₁ , b∈ys , v≈fxb
    combine-∈ f (x ∷ xs) ys v∈map++com | inj₂ v∈com with combine-∈ f xs ys v∈com
    ... | (a , b , a∈xs , b∈ys , v≈fab) = a , b , there a∈xs , b∈ys , v≈fab


  open TripleSetoid public

  -----------------------
  -- To push to stdlib --
  -----------------------



  