open import Data.Fin using (Fin)
open import Data.Fin.Properties using (_≟_)
open import Data.Nat using (ℕ; zero; _≤_; suc; s≤s; z≤n; _⊔_)
open import Data.Nat.Properties using (¬i+1+j≤i; n≤1+n; 1+n≰n; ≤-step)
open import Data.List using ([]; _∷_; map)
open import Data.List.Any using (here; module Membership)
open import Data.Maybe using (Maybe; nothing; just; Eq; drop-just)
open import Data.Product using (∃; ∄; _,_; _×_)
open import Data.Sum using (_⊎_; inj₁; inj₂)
open import Relation.Binary using (Total; Setoid; IsDecEquivalence; IsDecTotalOrder; IsPreorder; Decidable; _Respects₂_; _Preserves_⟶_)
open import Relation.Binary.On using () renaming (isDecEquivalence to on-isDecEquivalence; isDecTotalOrder to on-isDecTotalOrder; respects₂ to on-respects₂; isPreorder to on-isPreorder; decidable to on-decidable; total to on-total; setoid to on-setoid)
open import Relation.Binary.PropositionalEquality using (_≡_; _≢_; inspect; [_]; subst; subst₂; cong; cong₂) renaming (refl to ≡-refl; sym to ≡-sym; trans to ≡-trans; setoid to ≡-setoid)
open import Relation.Nullary using (yes; no; ¬_)
open import Relation.Nullary.Negation using (contradiction)
open import Function using (_∘_)

open import RoutingLib.Data.Graph
open import RoutingLib.Data.Graph.EGPath
open import RoutingLib.Data.Graph.EPath using (EPath; [_]; _∷_∣_) renaming (_≈ₚ_ to _≈ₚ′_; _≉ₚ_ to _≉ₚ′_; _≤ₚ_ to _≤ₚ′_; _≤ₗ_ to _≤ₗ′_; _∉_ to _∉′_; source to source′; notHere to notHere′; notThere to notThere′; allPaths to allPaths′)
open import RoutingLib.Data.Graph.EPath.Properties as EPathP using ()
open import RoutingLib.Data.List.All.Uniqueness using (Unique)
open import RoutingLib.Data.List.All.Uniqueness.Properties using (filter!)
open import RoutingLib.Data.List.All.Properties using (gfilter-pairs)
open import RoutingLib.Data.List.Any.GenericMembership using (∈-gfilter; ∈-map; ∃-foldr; map-∃-∈; gfilter-∈; ∈-resp-≈ₗ)
open import RoutingLib.Relation.Binary.RespectedBy using (_RespectedBy_; RespectedBy⇨Respects₂; Respects₂⇨RespectedBy)
open import RoutingLib.Relation.Binary
open import RoutingLib.Relation.Binary.On using () renaming (isDecTotalPreorder to on-isDecTotalPreorder)
open import RoutingLib.Data.Maybe.Properties using (just-injective) renaming (trans to eq-trans; sym to eq-sym; reflexive to eq-reflexive)
open import RoutingLib.Data.List.Folds using (foldr-⊎preserves)
open import RoutingLib.Data.Nat.Properties using (≤-refl; ⊔-⊎preserves-x≤; m<n⇨m≢n; ≤-trans; ⊔-sel)
open import RoutingLib.Relation.Binary.List.Pointwise using (≡⇒Rel≈)

module RoutingLib.Data.Graph.EGPath.Properties {a n} {A : Set a} {G : Graph A n} where

  --------------
  -- Equality --
  --------------

  ≈ₚ-isDecEquivalence : IsDecEquivalence (_≈ₚ_ {G = G})
  ≈ₚ-isDecEquivalence = on-isDecEquivalence toEPath EPathP.≈ₚ-isDecEquivalence

  open IsDecEquivalence ≈ₚ-isDecEquivalence using () renaming (
      refl to ≈ₚ-refl;
      sym to ≈ₚ-sym;
      trans to ≈ₚ-trans;
      _≟_ to _≟ₚ_;
      isEquivalence to ≈ₚ-isEquivalence;
      reflexive to ≈ₚ-reflexive
    ) public

  ≈ₚ-setoid : Setoid _ _
  ≈ₚ-setoid = record {
      Carrier = EGPath G ;
      _≈_ = _≈ₚ_ ;
      isEquivalence = ≈ₚ-isEquivalence
    }

  p≉i∷p : ∀ {p : EGPath G} {i i∉p} e∈G → p ≉ₚ i ∷ p ∣ i∉p ∣ e∈G
  p≉i∷p {[ _ ]} _  ()
  p≉i∷p {_ ∷ _ ∣ _ ∣ e∈G} _ (_ ∷ rec) = p≉i∷p e∈G rec

  p≈q⇨p₀≡q₀ : ∀ {p q : EGPath G} → p ≈ₚ q → source p ≡ source q
  p≈q⇨p₀≡q₀ {[ _ ]}         {[ _ ]}          [ ≡-refl ]   = ≡-refl
  p≈q⇨p₀≡q₀ {[ _ ]}         {_ ∷ _ ∣ _ ∣ _} ()
  p≈q⇨p₀≡q₀ {_ ∷ _ ∣ _ ∣ _} {[ _ ]}         ()
  p≈q⇨p₀≡q₀ {_ ∷ _ ∣ _ ∣ _} {_ ∷ _ ∣ _ ∣ _} (≡-refl ∷ _) = ≡-refl

  to[p]₀≡p₀ : ∀ (p : EGPath G) → source′ (toEPath p) ≡ source p
  to[p]₀≡p₀ [ _ ] = ≡-refl
  to[p]₀≡p₀ (_ ∷ _ ∣ _ ∣ _) = ≡-refl

  p≈q⇨pₙ≡qₙ : ∀ {p q : EGPath G} → p ≈ₚ q → destination p ≡ destination q
  p≈q⇨pₙ≡qₙ {[ _ ]}         {[ _ ]}          [ ≡-refl ] = ≡-refl
  p≈q⇨pₙ≡qₙ {[ _ ]}         {_ ∷ _ ∣ _ ∣ _} ()
  p≈q⇨pₙ≡qₙ {_ ∷ _ ∣ _ ∣ _} {[ _ ]}         ()
  p≈q⇨pₙ≡qₙ {_ ∷ _ ∣ _ ∣ _} {_ ∷ _ ∣ _ ∣ _} (_ ∷ p≈q)  = p≈q⇨pₙ≡qₙ p≈q

  p≈q⇨|p|≡|q| : ∀ {p q : EGPath G} → p ≈ₚ q → length p ≡ length q
  p≈q⇨|p|≡|q| {[ _ ]}         {[ _ ]}          [ ≡-refl ] = ≡-refl
  p≈q⇨|p|≡|q| {[ _ ]}         {_ ∷ _ ∣ _ ∣ _} ()
  p≈q⇨|p|≡|q| {_ ∷ _ ∣ _ ∣ _} {[ _ ]}         ()
  p≈q⇨|p|≡|q| {_ ∷ _ ∣ _ ∣ _} {_ ∷ _ ∣ _ ∣ _} (_ ∷ p≈q)  = cong suc (p≈q⇨|p|≡|q| p≈q)

  -------------------------
  -- Lexicographic order --
  -------------------------

  ≤ₚ-resp₂-≈ₚ : (_≤ₚ_ {G = G}) Respects₂ _≈ₚ_
  ≤ₚ-resp₂-≈ₚ = on-respects₂ toEPath _≤ₚ′_ _≈ₚ′_ EPathP.≤ₚ-resp₂-≈ₚ

  ≤ₚ-resp-≈ₚ : (_≤ₚ_ {G = G}) RespectedBy _≈ₚ_
  ≤ₚ-resp-≈ₚ = Respects₂⇨RespectedBy ≤ₚ-resp₂-≈ₚ

  ≤ₚ-isDecTotalOrder : IsDecTotalOrder (_≈ₚ_ {G = G}) _≤ₚ_
  ≤ₚ-isDecTotalOrder = on-isDecTotalOrder toEPath EPathP.≤ₚ-isDecTotalOrder

  open IsDecTotalOrder ≤ₚ-isDecTotalOrder using () renaming (
      refl to ≤ₚ-refl;
      trans to ≤ₚ-trans;
      antisym to ≤ₚ-antisym;
      total to ≤ₚ-total;
      _≤?_ to _≤ₚ?_
    ) public


  -- Other

  p≤ₚi∷p : ∀ {p : EGPath G} {i i∉p} e∈G → p ≤ₚ i ∷ p ∣ i∉p ∣ e∈G
  p≤ₚi∷p {[ _ ]} _   = stopLeft ≤ₚ-refl
  p≤ₚi∷p {_ ∷ _ ∣ _ ∣ e∈G} _ = stepUnequal (p≉i∷p e∈G) (p≤ₚi∷p e∈G)

  i∷p≰ₚp : ∀ {p : EGPath G} {i i∉p} e∈G → i ∷ p ∣ i∉p ∣ e∈G ≰ₚ p
  i∷p≰ₚp {p} {i} {i∉p} e∈G i∷p≤p = (p≉i∷p e∈G) (≤ₚ-antisym {p} {i ∷ p ∣ i∉p ∣ e∈G} (p≤ₚi∷p e∈G) i∷p≤p)

  p≈q∧ip₀∈G⇨iq₀∈G : {p q : EGPath G} → p ≈ₚ q → ∀ {i} → (i , source p) ᵉ∈ᵍ G → (i , source q) ᵉ∈ᵍ G
  p≈q∧ip₀∈G⇨iq₀∈G p≈q {i} ip₀∈G = subst (λ v → (i , v) ᵉ∈ᵍ G) (p≈q⇨p₀≡q₀ p≈q) ip₀∈G


  ------------------
  -- Length order --
  ------------------

  ≤ₗ-isDecTotalPreorder : IsDecTotalPreorder (_≈ₚ_ {G = G}) _≤ₗ_
  ≤ₗ-isDecTotalPreorder = on-isDecTotalPreorder toEPath EPathP.≤ₗ-isDecTotalPreorder

  open IsDecTotalPreorder ≤ₗ-isDecTotalPreorder using () renaming (
      refl to ≤ₗ-refl;
      trans to ≤ₗ-trans;
      total to ≤ₗ-total;
      _≤?_ to _≤ₗ?_;
      ∼-resp-≈ to ≤ₗ-resp₂-≈ₚ;
      isPreorder to ≤ₗ-isPreorder;
      isTotalPreorder to ≤ₗ-isTotalPreorder)
    public

  ≤ₗ-resp-≈ₚ : (_≤ₗ_ {G = G}) RespectedBy _≈ₚ_
  ≤ₗ-resp-≈ₚ = Respects₂⇨RespectedBy ≤ₗ-resp₂-≈ₚ

  i∷p≰ₗp : ∀ {i} {p : EGPath G} {i∉p} e∈G → i ∷ p ∣ i∉p ∣ e∈G ≰ₗ p
  i∷p≰ₗp _ = 1+n≰n

  p≤ₗi∷p : ∀ {p : EGPath G} {i i∉p} e∈G → p ≤ₗ i ∷ p ∣ i∉p ∣ e∈G
  p≤ₗi∷p {p} _ = n≤1+n (length p)


  -- Other

  _∉?_ : Decidable (_∉_ {G = G})
  i ∉? [ j ] with i ≟ j
  ... | yes i≡j           = no λ{(notThere i≢j) → i≢j i≡j}
  ... | no  i≢j           = yes (notThere i≢j)
  i ∉? (j ∷ p ∣ _ ∣ _) with i ≟ j | i ∉? p
  ... | yes i≡j | _       = no λ{(notHere i≢j _) → i≢j i≡j }
  ... | _       | no  i∈p = no λ{(notHere _ i∉p) → i∈p i∉p}
  ... | no  i≢j | yes i∉p = yes (notHere i≢j i∉p)

  ∉-resp-≈ₚ : ∀ {k} {p q : EGPath G} → p ≈ₚ q → k ∉ p → k ∉ q
  ∉-resp-≈ₚ {p = [ _ ]}         {[ _ ]}          [ ≡-refl ]     (notThere i≢j)    = notThere i≢j
  ∉-resp-≈ₚ {p = [ _ ]}         {_ ∷ _ ∣ _ ∣ _}  ()
  ∉-resp-≈ₚ {p = _ ∷ _ ∣ _ ∣ _} {[ _ ]}          ()
  ∉-resp-≈ₚ {p = _ ∷ _ ∣ _ ∣ _} {_ ∷ _ ∣ _ ∣ _}  (≡-refl ∷ p≈q) (notHere k≉x k∉p) = notHere k≉x (∉-resp-≈ₚ p≈q k∉p)


  weight-resp-≈ₚ : ∀ {b} {B : Set b} (▷ : A → B → B) (i : B) {p q : EGPath G} → p ≈ₚ q → weight ▷ i p ≡ weight ▷ i q
  weight-resp-≈ₚ _▷_ 1# {p = [ _ ]} {[ _ ]} _ = ≡-refl
  weight-resp-≈ₚ _▷_ 1# {p = [ _ ]} {_ ∷ p ∣ _ ∣ _} ()
  weight-resp-≈ₚ _▷_ 1# {p = _ ∷ _ ∣ _ ∣ _} {[ _ ]} ()
  weight-resp-≈ₚ _▷_ 1# {p = i ∷ p ∣ _ ∣ (v , e≡v) } {.i ∷ q ∣ _ ∣ (w , e≡w)} (≡-refl ∷ p≈q) =
    cong₂ _▷_
      (just-injective (≡-trans (≡-trans (≡-sym e≡v) (cong (G i) (p≈q⇨p₀≡q₀ p≈q))) e≡w))
      (weight-resp-≈ₚ _▷_ 1# p≈q)


  ----------------
  -- Conversion --
  ----------------

  toEPath-source : ∀ {p : EGPath G} {q} → (toEPath p) ≈ₚ′ q → source p ≡ source′ q
  toEPath-source {[ _ ]}         {[ _ ]}      [ ≡-refl ]   = ≡-refl
  toEPath-source {_ ∷ _ ∣ _ ∣ _} {_ ∷ _ ∣ _} (≡-refl ∷ _) = ≡-refl

  toEPath-cong : ∀ {p q : EGPath G} → p ≈ₚ q → toEPath p ≈ₚ′ toEPath q
  toEPath-cong {[ _ ]}          {[ _ ]}          [ ≡-refl ]  = [ ≡-refl ]
  toEPath-cong {[ _ ]}          {_ ∷ _ ∣ _ ∣ _} ()
  toEPath-cong {_ ∷ _ ∣ _ ∣ _} {[ _ ]}          ()
  toEPath-cong {_ ∷ _ ∣ _ ∣ _} {_ ∷ _ ∣ _ ∣ _}  (≡-refl ∷ p≈q) = ≡-refl ∷ (toEPath-cong p≈q)

  toEPath-∉₁ : ∀ {p : EGPath G} {q i} → toEPath p ≈ₚ′ q → i ∉ p → i ∉′ q
  toEPath-∉₁ {[ _ ]}         {[ _ ]}      [ ≡-refl ]     (notThere i≢j)    = notThere′ i≢j
  toEPath-∉₁ {_ ∷ _ ∣ _ ∣ _} {_ ∷ _ ∣ _} (≡-refl ∷ p≈q) (notHere i≢j i∉p) = notHere′ i≢j (toEPath-∉₁ p≈q i∉p)

  toEPath-∉₂ : ∀ {p : EGPath G} {q i} → toEPath p ≈ₚ′ q → i ∉′ q → i ∉ p
  toEPath-∉₂ {[ _ ]}         {[ _ ]}      [ ≡-refl ]     (notThere′ i≢j)    = notThere i≢j
  toEPath-∉₂ {_ ∷ _ ∣ _ ∣ _} {_ ∷ _ ∣ _} (≡-refl ∷ p≈q) (notHere′ i≢j i∉p) = notHere i≢j (toEPath-∉₂ p≈q i∉p)

  toEPath-fromEPath : ∀ {p : EPath n} {q : EGPath G} → fromEPath p G ≡ just q → p ≈ₚ′ toEPath q
  toEPath-fromEPath {[ _ ]}     {[ _ ]}         ≡-refl = [ ≡-refl ]
  toEPath-fromEPath {[ _ ]}     {_ ∷ _ ∣ _ ∣ _} ()
  toEPath-fromEPath {_ ∷ p ∣ _}                 _ with fromEPath p G | inspect (fromEPath p) G
  toEPath-fromEPath {_ ∷ _ ∣ _}                 ()     | nothing | _
  toEPath-fromEPath {i ∷ _ ∣ _}                 _      | just v  | [ _ ] with (i , source v) ᵉ∈ᵍ? G
  toEPath-fromEPath {_ ∷ _ ∣ _}                 ()     | just _  | [ _ ] | no _
  toEPath-fromEPath {_ ∷ _ ∣ _} {[ _ ]}         ()     | just _  | [ s ] | yes _
  toEPath-fromEPath {_ ∷ _ ∣ _} {_ ∷ _ ∣ _ ∣ _} ≡-refl | just _  | [ s ] | yes _ = ≡-refl ∷ toEPath-fromEPath s

  p≈fromtop : ∀ (p : EGPath G) → Eq _≈ₚ_ (fromEPath (toEPath p) G) (just p)
  p≈fromtop [ j ] = just [ ≡-refl ]
  p≈fromtop (i ∷ p ∣ i∉p ∣ e∈G) with fromEPath (toEPath p) G | inspect (fromEPath (toEPath p)) G
  ... | nothing | [ fromtop≡nothing ] = contradiction (eq-trans ≈ₚ-trans (eq-reflexive ≈ₚ-refl (≡-sym fromtop≡nothing)) (p≈fromtop p)) λ()
  ... | just v  | [ fromtop≡justv ] with (i , source v) ᵉ∈ᵍ? G
  ...    | no iv₀∉G = contradiction (p≈q∧ip₀∈G⇨iq₀∈G (≈ₚ-sym (drop-just (eq-trans ≈ₚ-trans (eq-reflexive ≈ₚ-refl (≡-sym fromtop≡justv)) (p≈fromtop p)))) e∈G) iv₀∉G
  ...    | yes _ = just (≡-refl ∷ drop-just (eq-trans ≈ₚ-trans (eq-reflexive ≈ₚ-refl (≡-sym fromtop≡justv)) (p≈fromtop p)))

  fromEPath-pres-≈ : ∀ {p q} → p ≈ₚ′ q → Eq _≈ₚ_ (fromEPath p G) (fromEPath q G)
  fromEPath-pres-≈ {[ _ ]} {[ _ ]} [ ≡-refl ] = just [ ≡-refl ]
  fromEPath-pres-≈ {[ _ ]} {_ ∷ _ ∣ _} ()
  fromEPath-pres-≈ {_ ∷ _ ∣ _} {[ _ ]} ()
  fromEPath-pres-≈ {i ∷ p ∣ _} {.i ∷ q ∣ _} (≡-refl ∷ p≈q) with fromEPath p G | inspect (fromEPath p) G | fromEPath q G | inspect (fromEPath q) G
  ... | nothing | _                 | nothing | _                 = nothing
  ... | nothing | [ fromp≡nothing ] | just y  | [ fromq≡justy ]   = contradiction (subst₂ (Eq _≈ₚ_) fromp≡nothing fromq≡justy (fromEPath-pres-≈ p≈q)) λ()
  ... | just x  | [ fromp≡justx ]   | nothing | [ fromq≡nothing ] = contradiction (subst₂ (Eq _≈ₚ_) fromp≡justx fromq≡nothing (fromEPath-pres-≈ p≈q)) λ()
  ... | just x  | [ fromp≡justx ]   | just y  | [ fromq≡justy ] with (i , source x) ᵉ∈ᵍ? G | (i , source y) ᵉ∈ᵍ? G
  ...   | no _      | no _      = nothing
  ...   | no  ix₀∉G | yes iy₀∈G = contradiction (p≈q∧ip₀∈G⇨iq₀∈G (≈ₚ-sym (drop-just (subst₂ (Eq _≈ₚ_) fromp≡justx fromq≡justy (fromEPath-pres-≈ p≈q)))) iy₀∈G) ix₀∉G
  ...   | yes ix₀∈G | no  iy₀∉G = contradiction (p≈q∧ip₀∈G⇨iq₀∈G (drop-just (subst₂ (Eq _≈ₚ_) fromp≡justx fromq≡justy (fromEPath-pres-≈ p≈q))) ix₀∈G) iy₀∉G
  ...   | yes _     | yes _     = just (≡-refl ∷ (drop-just (subst₂ (Eq _≈ₚ_) fromp≡justx fromq≡justy (fromEPath-pres-≈ p≈q))))

  fromEPath-pres-≉ : ∀ {p q} → p ≉ₚ′ q → (fromEPath p G ≡ nothing) ⊎ (fromEPath q G ≡ nothing) ⊎ (Eq _≉ₚ_ (fromEPath p G) (fromEPath q G))
  fromEPath-pres-≉ {[ i ]}     {[ j ]}     p≉q = inj₂ (inj₂ (just p≉q))
  fromEPath-pres-≉ {[ _ ]}     {j ∷ q ∣ _} p≉q with fromEPath q G | inspect (fromEPath q) G
  ... | nothing | _ = inj₂ (inj₁ ≡-refl)
  ... | just y  | _ with (j , source y) ᵉ∈ᵍ? G
  ...   | no  _ = inj₂ (inj₁ ≡-refl)
  ...   | yes _ = inj₂ (inj₂ (just λ()))
  fromEPath-pres-≉ {i ∷ p ∣ _} {[ _ ]}     p≉q with fromEPath p G | inspect (fromEPath p) G
  ... | nothing | _ = inj₁ ≡-refl
  ... | just x  | _ with (i , source x) ᵉ∈ᵍ? G
  ...   | no  _ = inj₁ ≡-refl
  ...   | yes _ = inj₂ (inj₂ (just λ()))
  fromEPath-pres-≉ {i ∷ p ∣ _} {j ∷ q ∣ _} i∷p≉j∷q  with fromEPath p G | inspect (fromEPath p) G | fromEPath q G | inspect (fromEPath q) G
  ... | nothing | _               | _       | _ = inj₁ ≡-refl
  ... | _       | _               | nothing | _ = inj₂ (inj₁ ≡-refl)
  ... | just x  | [ fromp≡justx ] | just y  | [ fromq≡justy ]   with (i , source x) ᵉ∈ᵍ? G | (j , source y) ᵉ∈ᵍ? G
  ...   | no  _ | _     = inj₁ ≡-refl
  ...   | _     | no _  = inj₂ (inj₁ ≡-refl)
  ...   | yes _ | yes _ with i ≟ j | EPathP._≟ₚ_ p q
  ...     | yes i≡j | yes p≈q = contradiction (i≡j ∷ p≈q) i∷p≉j∷q
  ...     | no  i≢j | _       = inj₂ (inj₂ (just (EPathP.p₀≢q₀⇨p≉q i≢j)))
  ...     | _       | no  p≉q with fromEPath-pres-≉ p≉q
  ...       | inj₁ fromp≡nothing        = contradiction (≡-trans (≡-sym fromp≡nothing) fromp≡justx) λ()
  ...       | inj₂ (inj₁ fromq≡nothing) = contradiction (≡-trans (≡-sym fromq≡nothing) fromq≡justy) λ()
  ...       | inj₂ (inj₂ fromp≉fromq)   = inj₂ (inj₂ (just (EPathP.pₜ≉qₜ⇨p≉q (drop-just (subst₂ (Eq _≉ₚ_) fromp≡justx fromq≡justy fromp≉fromq)))))



  ----------------
  -- Enumeraton --
  ----------------

  open Membership ≈ₚ-setoid using () renaming (_∈_ to _∈ₗ_)

  allPaths-complete : ∀ p → p ∈ₗ allPaths G
  allPaths-complete p = ∈-gfilter EPathP.≈ₚ-setoid ≈ₚ-setoid (λ p → fromEPath p G) (EPathP.allPaths-completeness (toEPath p)) (p≈fromtop p) fromEPath-pres-≈

  allPaths-unique : Unique ≈ₚ-setoid (allPaths G)
  allPaths-unique = gfilter-pairs (λ p → fromEPath p G) fromEPath-pres-≉ EPathP.allPaths!



  --------------
  -- Diameter --
  --------------

  -- isPathBetween

  isPathBetween-cong : ∀ src dst {p q : EGPath G} → p ≈ₚ q → Eq _≈ₚ_ (isPathBetween src dst p) (isPathBetween src dst q)
  isPathBetween-cong src dst {p} {q} p≈q with source p ≟ src | source q ≟ src | destination p ≟ dst | destination q ≟ dst
  ... | no  p₀≢src | yes q₀≡src | _          | _          = contradiction (≡-trans (p≈q⇨p₀≡q₀ p≈q)          q₀≡src) p₀≢src
  ... | yes p₀≡src | no  q₀≢src | _          | _          = contradiction (≡-trans (p≈q⇨p₀≡q₀ (≈ₚ-sym p≈q)) p₀≡src) q₀≢src
  ... | _          | _          | yes pₙ≡dst | no  qₙ≢dst = contradiction (≡-trans (p≈q⇨pₙ≡qₙ  (≈ₚ-sym p≈q)) pₙ≡dst) qₙ≢dst
  ... | _          | _          | no  pₙ≢dst | yes qₙ≡dst = contradiction (≡-trans (p≈q⇨pₙ≡qₙ  p≈q)          qₙ≡dst) pₙ≢dst
  ... | no  _      | no  _      | _          | _          = nothing
  ... | yes _      | yes _      | no  _      | no  _      = nothing
  ... | yes _      | yes _      | yes _      | yes _      = just p≈q

  isPathBetween-just : ∀ {src dst} {p : EGPath G} → source p ≡ src → destination p ≡ dst → Eq _≈ₚ_ (isPathBetween src dst p) (just p)
  isPathBetween-just {src} {dst} {p} p₀≡src pₙ≡dst with source p ≟ src | destination p ≟ dst
  ... | no  p₀≢src | _          = contradiction p₀≡src p₀≢src
  ... | _          | no  pₙ≢dst = contradiction pₙ≡dst pₙ≢dst
  ... | yes _      | yes _      = just ≈ₚ-refl

  just-isPathBetween : ∀ src dst p {q : EGPath G} → Eq _≈ₚ_ (isPathBetween src dst p) (just q) → source p ≡ src × destination p ≡ dst
  just-isPathBetween src dst p ≈just with source p ≟ src | destination p ≟ dst
  ... | no  _    | _        = contradiction ≈just λ()
  ... | yes _    | no  _    = contradiction ≈just λ()
  ... | yes p₀≡s | yes pₙ≡d = p₀≡s , pₙ≡d

  isPathBetween-idem : ∀ i j (p q : EGPath G) → Eq _≈ₚ_ (isPathBetween i j q) (just p) → Eq _≈ₚ_ (isPathBetween i j p) (just p)
  isPathBetween-idem i j p q ≈just with source q ≟ i | destination q ≟ j | source p ≟ i | destination p ≟ j
  ... | no  _    | _        | _        | _       = contradiction ≈just λ()
  ... | yes _    | no  _    | _        | _       = contradiction ≈just λ()
  ... | yes q₀≡i | yes _    | no  p₀≢i | _       = contradiction (≡-trans (p≈q⇨p₀≡q₀ (≈ₚ-sym (drop-just ≈just))) q₀≡i) p₀≢i
  ... | yes _    | yes qₙ≡i | yes _    | no pₙ≢i = contradiction (≡-trans (p≈q⇨pₙ≡qₙ (≈ₚ-sym (drop-just ≈just))) qₙ≡i) pₙ≢i
  ... | yes _    | yes _    | yes _    | yes _   = just ≈ₚ-refl

  -- allPathsBetween

  allPathsBetween-complete : ∀ {src} {dst} {p} → source p ≡ src → destination p ≡ dst → p ∈ₗ allPathsBetween G src dst
  allPathsBetween-complete {src} {dst} {p} p₀≡src pₙ=dst = ∈-gfilter ≈ₚ-setoid ≈ₚ-setoid (isPathBetween src dst) (allPaths-complete p) (isPathBetween-just p₀≡src pₙ=dst) (isPathBetween-cong src dst)

  ∈-allPathsBetween : ∀ {i} {j} {p} → p ∈ₗ allPathsBetween G i j → source p ≡ i × destination p ≡ j
  ∈-allPathsBetween {i} {j} {p} p∈apb with gfilter-∈ ≈ₚ-setoid (isPathBetween i j) (allPaths G) p∈apb
  ... | (q , q∈allPaths , ipbq≈justp) = just-isPathBetween i j p (isPathBetween-idem i j p q ipbq≈justp)

  -- diameterBetween

  |p|≤dᵢⱼ : ∀ {i j} (p : EGPath G) → source p ≡ i → destination p ≡ j → length p ≤ diameterBetween G i j
  |p|≤dᵢⱼ {i} {j} p p₀≡i pₙ≡j = foldr-⊎preserves (≡-setoid ℕ) ⊔-⊎preserves-x≤ (subst (length p ≤_)) zero (map length (allPathsBetween G i j)) (inj₂ (length p , ∈-map ≈ₚ-setoid (≡-setoid ℕ) p≈q⇨|p|≡|q| (allPathsBetween-complete p₀≡i pₙ≡j) , ≤-refl))

  dᵢⱼ≡0⇨∄p : ∀ {i j} → j ≢ i → diameterBetween G i j ≡ zero → ∄ λ (p : EGPath G) → source p ≡ i × destination p ≡ j
  dᵢⱼ≡0⇨∄p j≢i _    ([ _ ] ,           ≡-refl , ≡-refl) = contradiction ≡-refl j≢i
  dᵢⱼ≡0⇨∄p _   dᵢⱼ≡0 (k ∷ p ∣ k∉p ∣ e∈G , p₀≡i , pₙ≡j)   = contradiction (≡-sym dᵢⱼ≡0) (m<n⇨m≢n (≤-trans (s≤s z≤n) (|p|≤dᵢⱼ (k ∷ p ∣ k∉p ∣ e∈G) p₀≡i pₙ≡j)))

  ∄p⇨dᵢⱼ≡0 : ∀ i j → (∄ λ (p : EGPath G) → source p ≡ i × destination p ≡ j) → diameterBetween G i j ≡ zero
  ∄p⇨dᵢⱼ≡0 i j ∄p with allPathsBetween G i j | inspect (allPathsBetween G i) j
  ... | []     | _            = ≡-refl
  ... | p ∷ ps | [ apb≡p∷ps ] = contradiction (p , (∈-allPathsBetween (∈-resp-≈ₗ ≈ₚ-setoid (here ≈ₚ-refl) (≡⇒Rel≈ ≈ₚ-refl (≡-sym apb≡p∷ps))))) ∄p

  ∃-dᵢⱼ : ∀ i j → (∄ λ (p : EGPath G) → source p ≡ i × destination p ≡ j) ⊎ ∃ λ (p : EGPath G) → (source p ≡ i × destination p ≡ j) × (diameterBetween G i j ≡ length p)
  ∃-dᵢⱼ i j with ∃-foldr (≡-setoid ℕ) _⊔_ ⊔-sel zero (map length (allPathsBetween G i j)) | j ≟ i
  ... | inj₁ dᵢⱼ≡0   | yes j≡i = inj₂ ([ i ] , (≡-refl , ≡-sym j≡i) , dᵢⱼ≡0)
  ... | inj₁ dᵢⱼ≡0   | no  j≢i = inj₁ (dᵢⱼ≡0⇨∄p j≢i dᵢⱼ≡0)
  ... | inj₂ dᵢⱼ∈map | _       with map-∃-∈ ≈ₚ-setoid (≡-setoid ℕ) dᵢⱼ∈map
  ...   | p , p∈allPathsBetweenᵢⱼ , dᵢⱼ≡|p| = inj₂ (p , ∈-allPathsBetween p∈allPathsBetweenᵢⱼ , dᵢⱼ≡|p|)


  ----------------
  -- TruncateAt --
  ----------------

  truncateAt-source : ∀ {p : EGPath G} {i} → (i∈p : i ∈ p) → source (truncateAt i∈p) ≡ i
  truncateAt-source {[ j ]}         {i} i∈p with i ≟ j
  ... | yes i≡j = ≡-sym i≡j
  ... | no  i≢j = contradiction (notThere i≢j) i∈p
  truncateAt-source {j ∷ p ∣ _ ∣ _} {i} i∈p with i ≟ j
  ... | yes i≡j = ≡-sym i≡j
  ... | no  i≢j = truncateAt-source (i∈p ∘ notHere i≢j)

  truncateAt-destination : ∀ {p : EGPath G} {i} → (i∈p : i ∈ p) → destination (truncateAt i∈p) ≡ destination p
  truncateAt-destination {[ j ]}        {i} i∈p = ≡-refl
  truncateAt-destination {j ∷ p ∣ _ ∣ _} {i} i∈p with i ≟ j
  ... | yes i≡j = ≡-refl
  ... | no  i≢j = truncateAt-destination (i∈p ∘ notHere i≢j)

  truncateAt-length : ∀ {p : EGPath G} {i} → (i∉p : i ∈ p) → length (truncateAt i∉p) ≤ length p
  truncateAt-length {[ j ]}        {i} i∈p = z≤n
  truncateAt-length {j ∷ p ∣ _ ∣ _} {i} i∈p with i ≟ j
  ... | yes i≡j = s≤s ≤-refl
  ... | no  i≢j = ≤-step (truncateAt-length (i∈p ∘ notHere i≢j))




  -----------
  -- Other --
  -----------

  p₀∈p : ∀ (p : EGPath G) → source p ∈ p
  p₀∈p [ i ]          (notThere i≢i)   = i≢i ≡-refl
  p₀∈p (i ∷ _ ∣ _ ∣ _) (notHere  i≢i _) = i≢i ≡-refl

  pₙ∈p : ∀ (p : EGPath G) → destination p ∈ p
  pₙ∈p [ i ]          (notThere i≢i)    = i≢i ≡-refl
  pₙ∈p (_ ∷ p ∣ _ ∣ _) (notHere  _ pₙ∉p) = pₙ∈p p pₙ∉p

  p₀≡pₙ⇨p≈[p₀] : ∀ {p : EGPath G} → source p ≡ destination p → p ≈ₚ [ source p ]
  p₀≡pₙ⇨p≈[p₀] {[ i ]}          _    = ≈ₚ-refl
  p₀≡pₙ⇨p≈[p₀] {i ∷ p ∣ i∉p ∣ _} i≡pₙ = contradiction i∉p (subst (_∈ p) (≡-sym i≡pₙ) (pₙ∈p p))