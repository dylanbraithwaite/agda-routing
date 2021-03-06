------------------------------------------------------------------------
-- Copied from the stdlib v0.17
------------------------------------------------------------------------

module RoutingLib.Data.Nat.DivMod where

open import Agda.Builtin.Nat using (div-helper; mod-helper)

open import Data.Fin using (Fin; zero; toℕ; fromℕ≤″; fromℕ≤)
open import Data.Fin.Properties using (toℕ<n; fromℕ≤-toℕ)
open import Data.Nat
open import Data.Nat.Properties using (≤⇒≤″; +-assoc; +-comm; +-identityʳ)
open import Data.Nat.DivMod
open import Relation.Binary.PropositionalEquality

open import RoutingLib.Data.Nat.DivMod.Core
open import RoutingLib.Data.Fin.Properties

open ≡-Reasoning

------------------------------------------------------------------------
-- _%_

a%n≤a : ∀ a n → a % (suc n) ≤ a
a%n≤a a n = a[modₕ]n≤a 0 a n

a%[1+n]≤n : ∀ a n → a % suc n ≤ n
a%[1+n]≤n a n = mod-lemma 0 a n

a≤n⇒a%n≡a : ∀ {a n} → a ≤ n → a % suc n ≡ a
a≤n⇒a%n≡a {a} {n} a≤n with ≤⇒≤″ a≤n
... | less-than-or-equal {k} refl = modₕ-skipToEnd 0 (a + k) a k

[a∸a%n]%n≡0 : ∀ a n → (a ∸ a % suc n) % suc n ≡ 0
[a∸a%n]%n≡0 a n = modₕ-minus 0 a n

+ˡ-% : ∀ a b {n} → a % suc n ≡ 0 → (a + b) % suc n ≡ b % suc n
+ˡ-% a b {n} eq = begin
  (a + b) % suc n                 ≡⟨ %-distribˡ-+ a b n ⟩
  (a % suc n + b % suc n) % suc n ≡⟨ cong (λ v → (v + b % suc n) % suc n) eq ⟩
  (b % suc n) % suc n             ≡⟨ a%n%n≡a%n b n ⟩
  b % suc n                       ∎

+ʳ-% : ∀ a b {n} → b % suc n ≡ 0 → (a + b) % suc n ≡ a % suc n
+ʳ-% a b {n} eq = trans (cong (_% suc n) (+-comm a b)) (+ˡ-% b a eq)





%⇒mod≡0 : ∀ a {n} → a % suc n ≡ zero → a mod suc n ≡ zero
%⇒mod≡0 a eq = fromℕ≤-cong _ (s≤s z≤n) eq

n[mod]n≡0 : ∀ n → suc n mod suc n ≡ zero
n[mod]n≡0 n = fromℕ≤-cong _ (s≤s z≤n) (n%n≡0 n)

toℕ-mod : ∀ {n} (i : Fin (suc n)) → toℕ i mod suc n ≡ i
toℕ-mod {n} i = begin
  fromℕ≤ (a%n<n (toℕ i) n)  ≡⟨ fromℕ≤-cong _ _ (a≤n⇒a%n≡a (≤-pred (toℕ<n i))) ⟩
  fromℕ≤ (toℕ<n i)          ≡⟨ fromℕ≤-toℕ i (toℕ<n i) ⟩
  i                         ∎


+ˡ-mod : ∀ a b {n} → a mod suc n ≡ zero → (a + b) mod suc n ≡ b mod suc n
+ˡ-mod a b eq = fromℕ≤-cong _ _ (+ˡ-% a b (fromℕ≤-injective _ (s≤s z≤n) eq))

+ʳ-mod : ∀ a b {n} → b mod suc n ≡ zero → (a + b) mod suc n ≡ a mod suc n
+ʳ-mod a b eq = fromℕ≤-cong _ _ (+ʳ-% a b (fromℕ≤-injective _ (s≤s z≤n) eq))
