open import Data.List using (lookup)
open import Data.List.Any as Any using (Any; here; there; index)
open import Relation.Unary using (Pred)

module RoutingLib.Data.List.Any.Properties where

module _ {a p} {A : Set a} {P : Pred A p} where

  lookup-index : ∀ {xs} (p : Any P xs) → P (lookup xs (index p))
  lookup-index (here px)   = px
  lookup-index (there pxs) = lookup-index pxs
