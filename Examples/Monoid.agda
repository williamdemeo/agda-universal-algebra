{- Definition of the theory of Monoids. Examples of monoids and a
   homomorphism between them. 
   Bijection between the standard library definition of monoids
   and the universal algebra approach. -}
module Examples.Monoid where

open import UnivAlgebra
open import Equational
open import Morphisms
open import SigMorphism
open import Data.Unit hiding (setoid)
open import Data.List
open import Data.Product
open import Data.Nat
open import Data.Sum
open import HeterogeneousVec
open import Setoids

open Signature
open Algebra
open Hom

data op-mon : List ⊤ × ⊤ → Set where
  e    : op-mon ([] ↦ tt)
  op   : op-mon ((tt ∷ [ tt ]) ↦ tt)


Σ-mon : Signature
Σ-mon = record { sorts = ⊤ ; ops = op-mon }



{- Booleans with false and ∨ are a monoid. -}
module ∨-Monoid where
  open import Data.Bool
  open import Relation.Binary.PropositionalEquality using (setoid;refl;_≡_)
  open import Function.Equality as FE renaming (_∘_ to _∘ₛ_) hiding (setoid)

  ∨-Monₛ : ⊤ → _
  ∨-Monₛ tt = setoid Bool

  ∨-Monₒ : ∀ {ar s } → ops Σ-mon (ar , s) → (∨-Monₛ ✳ ar) ⟶ ∨-Monₛ s
  _⟨$⟩_(∨-Monₒ e) ⟨⟩ = false
  _⟨$⟩_ (∨-Monₒ op) ⟨⟨ b₁ , b₂ ⟩⟩ = b₁ ∨ b₂

  cong (∨-Monₒ e) ∼⟨⟩ = {!!}
  cong (∨-Monₒ op) (∼▹ x x₁) = {!!}

  ∨-Alg : Algebra Σ-mon
  ∨-Alg = record {_⟦_⟧ₛ = ∨-Monₛ;
                  _⟦_⟧ₒ = ∨-Monₒ
                 }

  ∨-Monₒ e = record { _⟨$⟩_ = λ { ⟨⟩  → false }; cong = λ { ∼⟨⟩ → refl }}
  ∨-Monₒ op = record { _⟨$⟩_ = ∨-fun ; cong = ∨-cong }
         where ∨-fun : HVec (λ _ → Bool) (tt ∷ [ tt ]) → Bool
               ∨-fun (b ▹ b' ▹ ⟨⟩) = b ∨ b'
               ∨-cong : ∀ {bs bs'} → _∼v_ {R = λ _ → _≡_} bs bs' → ∨-fun bs ≡ ∨-fun bs'
               ∨-cong (∼▹ refl (∼▹ refl ∼⟨⟩)) = refl

  ∨-Alg : Algebra Σ-mon
  ∨-Alg = ∨-Monₛ ∥ ∨-Monₒ


  ∧-Monₛ : ⊤ → _
  ∧-Monₛ tt = setoid Bool

  ∧-Monₒ : ∀ {ar s } → ops Σ-mon (ar , s) → (∧-Monₛ ✳ ar) ⟶ ∧-Monₛ s
  ∧-Monₒ e = record { _⟨$⟩_ = λ { ⟨⟩  → true }; cong = λ { ∼⟨⟩ → refl }}
  ∧-Monₒ op = record { _⟨$⟩_ = ∧-fun ; cong = ∧-cong }
         where ∧-fun : HVec (λ _ → Bool) (tt ∷ [ tt ]) → Bool
               ∧-fun (b ▹ b' ▹ ⟨⟩) = b ∧ b'
               ∧-cong : ∀ {bs bs'} → _∼v_ {R = λ _ → _≡_} bs bs' → ∧-fun bs ≡ ∧-fun bs'
               ∧-cong (∼▹ refl (∼▹ refl ∼⟨⟩)) = refl

  ∧-Alg : Algebra Σ-mon
  ∧-Alg = ∧-Monₛ ∥ ∧-Monₒ

  open import Morphisms
  ¬-⟿ : ∨-Alg ⟿ ∧-Alg
  ¬-⟿ = λ s → record { _⟨$⟩_ = λ x → not x ; cong = λ { refl → refl }}

  ¬-cond : homCond ∨-Alg ∧-Alg ¬-⟿
  ¬-cond {.[]} {.tt} e ⟨⟩ = refl
  ¬-cond {.(tt ∷ tt ∷ [])} {.tt} op (false ▹ b' ▹ ⟨⟩) = refl
  ¬-cond {.(tt ∷ tt ∷ [])} {.tt} op (true ▹ b' ▹ ⟨⟩) = refl

  ¬-Hom : Homo ∨-Alg ∧-Alg
  ¬-Hom = record { ′_′ = ¬-⟿ ; cond = ¬-cond }


module Theory where

  X : Vars Σ-mon
  X ⊤ = ℕ

  Eq₁ : Set
  Eq₁ = Equation Σ-mon X tt

  open import TermAlgebra

  
  -- A formula is a term of the Term Algebra
  Form : Set
  Form = HU (Σ-mon 〔 X 〕) tt


  module Smartcons where
    -- smart constructors
    _∘_ : Form → Form → Form
    φ ∘ ψ = term op ⟨⟨ φ , ψ ⟩⟩

    x : Form
    x = term (inj₂ 0) ⟨⟩
    
    y : Form
    y = term (inj₂ 1) ⟨⟩

    z : Form
    z = term (inj₂ 2) ⟨⟩

    u : Form
    u = term (inj₁ e) ⟨⟩

  open Smartcons
  -- Axioms
  assocOp : Eq₁
  assocOp = ⋀ (x ∘ y) ∘ z ≈ (x ∘ (y ∘ z))

  unitLeft : Eq₁
  unitLeft = ⋀ u ∘ x ≈ x

  unitRight : Eq₁
  unitRight = ⋀ x ∘ u ≈ x

  MonTheory : Theory Σ-mon X (tt ∷ tt ∷ [ tt ])
  MonTheory = assocOp ▹ (unitLeft ▹ unitRight ▹ ⟨⟩)


  module Monoids where
    open import Algebra.Structures
    open import Data.Bool
    open import Relation.Binary.Core as BC
    
    MkMonoid : ∀ {a l A _≈_ _∘_} {e : A} → (m : IsMonoid {a} {l} _≈_ _∘_ e) → Algebra {a} {l} Σ-mon 
    MkMonoid {A = A} {_≈_} {_∘_} {eA} isMon = (λ _ → record { Carrier = A ; _≈_ = _≈_
                                                       ; isEquivalence = isEquivalence  })
                                       ∥ (λ { e → record { _⟨$⟩_ = λ x₁ → eA ; cong = λ {i} {j} _ →
                                                                                          BC.IsEquivalence.refl
                                                                                          (IsSemigroup.isEquivalence (isSemigroup )) }
                                         ; op → record { _⟨$⟩_ = λ { (v ▹ v₁ ▹ ⟨⟩) → v ∘ v₁ }
                                         ; cong = λ { (∼▹ x₁ (∼▹ x₂ ∼⟨⟩)) → ∙-cong x₁ x₂ } } })
             where open IsMonoid isMon


    {- Each monoid is a model of our theory. -}
    MonoidModel : ∀ {a l A _≈_ _∘_} {e : A} → (m : IsMonoid {a} {l} _≈_ _∘_ e) → MkMonoid m ⊨T MonTheory
    MonoidModel m here θ ∼⟨⟩ = IsSemigroup.assoc (isSemigroup m) (θ 0) (θ 1) (θ 2)
      where open IsMonoid
    MonoidModel m (there here) θ ∼⟨⟩ = proj₁ (identity m) (θ 0) 
      where open IsMonoid
    MonoidModel m (there (there here)) θ x₂ = proj₂ (identity m) (θ 0)
      where open IsMonoid
    MonoidModel m (there (there (there ()))) θ x₂


    open Algebra
    open import Relation.Binary hiding (Total)
    open Setoid
    open import Function.Equality
    open import Data.Unit
    {- and we can also build a monoid from a model. -}
    fromModel : ∀ {ℓ a} {A : Algebra {ℓ} {a} Σ-mon} → A ⊨T MonTheory → IsMonoid (_≈_ (A ⟦ tt ⟧ₛ))
                                                                                (λ x y → A ⟦ op ⟧ₒ ⟨$⟩ ⟨⟨ x , y ⟩⟩ )
                                                                                (A ⟦ e ⟧ₒ ⟨$⟩ ⟨⟩)
    fromModel {A = A} mod = record { isSemigroup = record { isEquivalence = isEquivalence (A ⟦ tt ⟧ₛ)
                                                          ; assoc = λ x₁ y₁ z₁ → mod here (η x₁ y₁ z₁) ∼⟨⟩
                                                          ; ∙-cong = λ x₁ x₂ → cong (_⟦_⟧ₒ A op) (∼▹ x₁ (∼▹ x₂ ∼⟨⟩)) }
                                   ; identity = (λ x₁ → mod (there here) (λ x₂ → x₁) ∼⟨⟩)
                                              , (λ x₁ → mod (there (there here)) (λ _ → x₁) ∼⟨⟩)
                                   }
      where η : ∥ A ⟦ tt ⟧ₛ ∥ → ∥ A ⟦ tt ⟧ₛ ∥ → ∥ A ⟦ tt ⟧ₛ ∥ → Env X A
            η a b c zero = a
            η a b c (suc zero) = b
            η a b c (suc (suc x₁)) = c

