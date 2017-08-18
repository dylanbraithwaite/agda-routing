open import Data.Fin using (Fin) renaming (zero to fzero; suc to fsuc)
open import Data.Nat
open import Data.List using (List; concat; tabulate)
open import Data.Product using (∃₂)
open import Relation.Unary using (Pred)
open import Algebra.FunctionProperties using (Op₂)
open import Function using (_∘_)

import RoutingLib.Data.Table as Table

module RoutingLib.Data.Matrix where
    
  Matrix : ∀ {a} → Set a → ℕ → ℕ → Set a
  Matrix A m n = Fin m → Fin n → A

  SquareMatrix : ∀ {a} → Set a → ℕ → Set a
  SquareMatrix A n = Matrix A n n
  
  -- Predicates

  All : ∀ {a ℓ} {A : Set a} → Pred A ℓ → ∀ {m n} → Pred (Matrix A m n) ℓ
  All P M = ∀ i j → P (M i j)

  Any : ∀ {a ℓ} {A : Set a} → Pred A ℓ → ∀ {m n} → Pred (Matrix A m n) ℓ
  Any P M = ∃₂ λ i j → P (M i j)

  -- Operations

  toList : ∀ {a m n} {A : Set a} → Matrix A m n → List A
  toList M = concat (tabulate (λ i → Table.toList (M i)))

  map : ∀ {a b} {A : Set a} {B : Set b} → (A → B) →
        ∀ {m n} → Matrix A m n → Matrix B m n
  map f M i j = f (M i j)
  
  zipWith : ∀ {a b c m n} {A : Set a} {B : Set b} {C : Set c} →
            (A → B → C) → Matrix A m n → Matrix B m n → Matrix C m n
  zipWith f M N i j = f (M i j) (N i j)

  fold : ∀ {a b} {A : Set a} {B : Set b} →
           (A → B → B) → B → ∀ {m n} → Matrix A m n → B
  fold f e M = Table.foldr (λ t e → Table.foldr f e t) e M
  
  fold⁺ : ∀ {a} {A : Set a} → Op₂ A → ∀ {m n} → Matrix A (suc m) (suc n) → A
  fold⁺ _•_ M = fold _•_ (Table.foldr⁺ _•_ (M fzero)) (M ∘ fsuc)

  max⁺ : ∀ {m n} → Matrix ℕ (suc m) (suc n) → ℕ
  max⁺ M = fold⁺ _⊔_ M

  min⁺ : ∀ {m n} → Matrix ℕ (suc m) (suc n) → ℕ
  min⁺ M = fold⁺ _⊓_ M
