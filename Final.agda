open import lib.Preliminaries

module Final where
  
  postulate
    Int    : Set
    Float  : Set

  {-# BUILTIN INTEGER Int #-}
  {-# BUILTIN FLOAT Float #-}

  primitive
    primFloatPlus    : Float → Float → Float
    primFloatMinus   : Float → Float → Float
    primFloatTimes   : Float → Float → Float
    primFloatDiv     : Float → Float → Float
    primSin          : Float → Float
    primFloatLess    : Float → Float → Bool
  
  _f+_ : Float → Float → Float
  x f+ y = primFloatPlus x y
 
  _f−_ : Float → Float → Float --\minus
  x f− y = primFloatMinus x y

  _f×_ : Float → Float → Float --\times
  x f× y = primFloatTimes x y

  _f÷_ : Float → Float → Float --\div
  x f÷ y = primFloatDiv x y
 
  ~_ : Float → Float
  ~ x = primFloatMinus 0.0 x

  infix 10 ~_

  --absolute value
  abs : Float → Float
  abs x with primFloatLess x 0.0 
  abs x | True = ~ x
  abs x | False = x
  
  π : Float
  π = 3.141592653589793238462643383279502884197169399375105820974944592307816406286
 
{-
  --approximation algorithm for square roots of floats
  -- x : the number to take the square root of t ≥ 0
  -- ε : the relative error tolerance
  -- t : initial guess of root
  newtonian : Float → Float → Float → Float
  newtonian x ε t with primFloatLess (ε f× t) (abs (t f− (x f÷ t)))
  newtonian x ε t | True = newtonian x ε (((x f÷ t) f+ t) f÷ 2.0)
  newtonian x ε t | False = t

  √ : Float → Float
  √ x = newtonian x 0.0000001 2.0
-}
  
  --datatype for base units
  -- "-" at the end represents ^-1
  data BaseU : Set where
    noU      : BaseU
    meter    : BaseU
    meter-   : BaseU
    gram     : BaseU
    gram-    : BaseU
    second   : BaseU
    second-  : BaseU
    ampere   : BaseU
    ampere-  : BaseU
    kelvin   : BaseU
    kelvin-  : BaseU
    candela  : BaseU
    candela- : BaseU
    mol      : BaseU
    mol-     : BaseU
  
  --datatype for complex units
  --all units can be created by multiplying basic (including inverse) units together
  data Units : Set where
    U        : BaseU → Units
    _u×_     : Units → Units → Units

  infixl 10 _u×_

  --datatype for prefixes
  data Prefix : Set where
    yotta : Prefix
    zetta : Prefix
    exa   : Prefix
    peta  : Prefix
    tera  : Prefix
    giga  : Prefix
    mega  : Prefix
    kilo  : Prefix
    hecto : Prefix
    deca  : Prefix
    deci  : Prefix 
    centi : Prefix
    milli : Prefix
    micro : Prefix
    nano  : Prefix
    pico  : Prefix
    femto : Prefix
    atto  : Prefix
    zepto : Prefix
    yocto : Prefix

  --prefixed takes a float and a prefix and multiplies by the corresponding factor of 10
  prefixed : Float → Prefix → Float
  prefixed f yotta = f f× 1.0e24
  prefixed f zetta = f f× 1.0e21
  prefixed f exa = f f× 1.0e18
  prefixed f peta = f f× 1.0e15
  prefixed f tera = f f× 1.0e12
  prefixed f giga = f f× 1.0e9
  prefixed f mega = f f× 1000000.0
  prefixed f kilo = f f× 1000.0
  prefixed f hecto = f f× 100.0
  prefixed f deca = f f× 10.0
  prefixed f deci = f f÷ 10.0
  prefixed f centi = f f÷ 100.0
  prefixed f milli = f f÷ 1000.0
  prefixed f micro = f f÷ 1000000.0
  prefixed f nano = f f÷ 1.0e9
  prefixed f pico = f f÷ 1.0e12
  prefixed f femto = f f÷ 1.0e15
  prefixed f atto = f f÷ 1.0e18
  prefixed f zepto = f f÷ 1.0e21
  prefixed f yocto = f f÷ 1.0e24

  --removes excess noU's
  filternoU : Units → Units
  filternoU (x u× (U noU)) = filternoU x
  filternoU (U noU u× x) = filternoU x
  filternoU (x u× x1) with filternoU x | filternoU x1
  ... | U noU | U noU = U noU
  ... | u | U noU = u
  ... | U noU | u = u
  ... | u1 | u2 = u1 u× u2
  filternoU x = x

  --inverts a unit (changes u to 1/u)
  flip : Units → Units
  flip (U noU) = U noU
  flip (U meter) = (U meter-)
  flip (U meter-) = (U meter)
  flip (U gram) = U gram-
  flip (U gram-) = U gram
  flip (U second) = U second-
  flip (U second-) = U second
  flip (U ampere) = U ampere-
  flip (U ampere-) = U ampere
  flip (U kelvin) = U kelvin-
  flip (U kelvin-) = U kelvin
  flip (U candela) = U candela-
  flip (U candela-) = U candela
  flip (U mol) = U mol-
  flip (U mol-) = U mol
  flip (x1 u× x2) = (flip x1) u× (flip x2)

  --cancels u with 1/u
  --recursion permissions could be used to convince the termination checker that
  --  this does in fact terminate (just like suffix in hw7) we dig deaper into
  --  the first term of x until we find a base unit then cancel appropriately
  cancel : Units → Units → Units
  cancel (U noU) x = x
  cancel (U meter) (U noU) = (U meter)
  cancel (U meter) (U meter-) = U noU
  cancel (U meter) ((U noU) u× y1) = cancel (U meter) y1
  cancel (U meter) ((U meter-) u× y1) = y1
  cancel (U meter) ((y u× y1) u× y2) = cancel (U meter) (y u× (y1 u× y2))
  cancel (U meter) (x u× y) = x u× cancel (U meter) y
  cancel (U meter-) (U noU) = U meter-
  cancel (U meter-) (U meter) = U noU
  cancel (U meter-) ((U noU) u× y1) = cancel (U meter-) y1
  cancel (U meter-) ((U meter) u× y1) = y1
  cancel (U meter-) ((y u× y1) u× y2) = cancel (U meter-) (y u× (y1 u× y2))
  cancel (U meter-) (x u× y) = x u× cancel (U meter-) y
  cancel (U gram) (U noU) = U gram
  cancel (U gram) (U gram-) = U noU
  cancel (U gram) ((U noU) u× y1) = cancel (U gram) y1
  cancel (U gram) ((U gram-) u× y1) = y1
  cancel (U gram) ((y u× y1) u× y2) = cancel (U gram) (y u× (y1 u× y2))
  cancel (U gram) (x u× y) = x u× cancel (U gram) y
  cancel (U gram-) (U noU) = U gram-
  cancel (U gram-) (U gram) = U noU
  cancel (U gram-) (U noU u× y1) = cancel (U gram-) y1
  cancel (U gram-) ((U gram) u× y1) = y1
  cancel (U gram-) ((y u× y1) u× y2) = cancel (U gram-) (y u× (y1 u× y2))
  cancel (U gram-) (x u× y) = x u× cancel (U gram-) y
  cancel (U second) (U noU) = U second
  cancel (U second) (U second-) = U noU
  cancel (U second) ((U noU) u× y1) = cancel (U second) y1
  cancel (U second) ((U second-) u× y1) = y1
  cancel (U second) ((y u× y1) u× y2) = cancel (U second) (y u× (y1 u× y2))
  cancel (U second) (x u× y) = x u× cancel (U second) y
  cancel (U second-) (U noU) = U second-
  cancel (U second-) (U second-) = U noU
  cancel (U second-) (U noU u× y1) = cancel (U second-) y1
  cancel (U second-) ((U second) u× y1) = y1
  cancel (U second-) ((y u× y1) u× y2) = cancel (U second-) (y u× (y1 u× y2))
  cancel (U second-) (x u× y) = x u× cancel (U second-) y
  cancel (U ampere) (U noU) = U ampere
  cancel (U ampere) (U ampere-) = U noU
  cancel (U ampere) ((U noU) u× y1) = cancel (U ampere) y1
  cancel (U ampere) ((U ampere-) u× y1) = y1
  cancel (U ampere) ((y u× y1) u× y2) = cancel (U ampere) (y u× (y1 u× y2))
  cancel (U ampere) (x u× y) = x u× cancel (U ampere) y
  cancel (U ampere-) (U noU) = U ampere-
  cancel (U ampere-) (U ampere) = U noU
  cancel (U ampere-) ((U noU) u× y1) = cancel (U ampere-) y1
  cancel (U ampere-) ((U ampere) u× y1) = y1
  cancel (U ampere-) ((y u× y1) u× y2) = cancel (U ampere-) (y u× (y1 u× y2))
  cancel (U ampere-) (x u× y) = x u× cancel (U ampere-) y
  cancel (U kelvin) (U noU) = U kelvin
  cancel (U kelvin) (U kelvin-) = U noU
  cancel (U kelvin) ((U noU) u× y1) = cancel (U kelvin) y1
  cancel (U kelvin) ((U kelvin-) u× y1) = y1
  cancel (U kelvin) ((y u× y1) u× y2) = cancel (U kelvin) (y u× (y1 u× y2))
  cancel (U kelvin) (x u× y) = x u× cancel (U kelvin) y
  cancel (U kelvin-) (U noU) = U kelvin-
  cancel (U kelvin-) (U kelvin) = U noU
  cancel (U kelvin-) ((U noU) u× y1) = cancel (U kelvin-) y1
  cancel (U kelvin-) ((U kelvin) u× y1) = y1
  cancel (U kelvin-) ((y u× y1) u× y2) = cancel (U kelvin-) (y u× (y1 u× y2))
  cancel (U kelvin-) (x u× y) = x u× cancel (U kelvin-) y
  cancel (U candela) (U noU) = U candela
  cancel (U candela) (U candela-) = U noU
  cancel (U candela) ((U noU) u× y1) = cancel (U candela) y1
  cancel (U candela) ((U candela-) u× y1) = y1
  cancel (U candela) ((y u× y1) u× y2) = cancel (U candela) (y u× (y1 u× y2))
  cancel (U candela) (x u× y) = x u× cancel (U candela) y
  cancel (U candela-) (U noU) = U candela-
  cancel (U candela-) (U candela) = U noU
  cancel (U candela-) ((U noU) u× y1) = cancel (U candela-) y1
  cancel (U candela-) ((U candela) u× y1) = y1
  cancel (U candela-) ((y u× y1) u× y2) = cancel (U candela-) (y u× (y1 u× y2))
  cancel (U candela-) (x u× y) = x u× cancel (U candela-) y
  cancel (U mol) (U noU) = U mol
  cancel (U mol) (U mol-) = U noU
  cancel (U mol) ((U noU) u× y1) = cancel (U mol) y1
  cancel (U mol) ((U mol-) u× y1) = y1
  cancel (U mol) ((y u× y1) u× y2) = cancel (U mol) (y u× (y1 u× y2))
  cancel (U mol) (x u× y) = x u× cancel (U mol) y
  cancel (U mol-) (U noU) = U mol-
  cancel (U mol-) (U mol) = U noU
  cancel (U mol-) ((U noU) u× y1) = cancel (U mol-) y1
  cancel (U mol-) ((U mol) u× y1) = y1
  cancel (U mol-) ((y u× y1) u× y2) = cancel (U mol-) (y u× (y1 u× y2))
  cancel (U mol-) (x u× y) = x u× cancel (U mol-) y
  cancel x y = x u× y

  reduce : Units → Units
  reduce ((U noU) u× u1) = reduce u1
  reduce (u1 u× (U noU)) = reduce u1
  reduce ((u u× u1) u× u2) = reduce (u u× (u1 u× u2))
  reduce (u u× u1) = cancel u (reduce u1)
  reduce u = u
  
  --checks if two base units are equal
  check=BaseU : BaseU → BaseU → Bool
  check=BaseU noU noU = True
  check=BaseU meter meter = True
  check=BaseU meter- meter- = True
  check=BaseU gram gram = True
  check=BaseU gram- gram- = True
  check=BaseU second second = True
  check=BaseU second- second- = True
  check=BaseU ampere ampere = True
  check=BaseU ampere- ampere- = True
  check=BaseU kelvin kelvin = True
  check=BaseU kelvin- kelvin- = True
  check=BaseU candela candela = True
  check=BaseU candela- candela- = True
  check=BaseU mol mol = True
  check=BaseU x y = False
  
 --floats all units of type BaseU to the front
  order-u : BaseU → Units → Units
  order-u x ((U u) u× us) with check=BaseU x u
  ... | True = U u u× order-u x us
  ... | False = order-u x us u× U u
  order-u x ((u u× u1) u× us) = order-u x (u u× (u1 u× us)) 
  order-u x u = u

  --imposes an ordering on units
  --this is needed in order to add, for example (meter u× second-) and (second- u× meter)
  order : Units → Units
  order u = order-u noU (order-u meter
              (order-u mol- (order-u candela- (order-u kelvin- (order-u ampere- (order-u second- (order-u gram- (order-u meter- 
               (order-u mol (order-u candela (order-u kelvin (order-u ampere (order-u second (order-u gram u))))))))))))))

  --datatype for united-floats and expressions using them
  data UF : Units → Set where
    V    : (f : Float) → (U : Units) → UF (order U)
    P    : (f : Float) → (p : Prefix) → (U : Units) → UF (order U)
    _`+_ : {U : Units} → UF U → UF U → UF U
    _`-_ : {U : Units} → UF U → UF U → UF U
    _`×_ : {U1 U2 : Units} → UF U1 → UF U2 → UF (order (filternoU (reduce (U1 u× U2))))
    _`÷_ : {U1 U2 : Units} → UF U1 → UF U2 → UF (order (filternoU (reduce (U1 u× flip U2))))
--    `√_  : {U : Units} → UF (U u× U) → UF U

  infixl 8 _`×_
  infixl 8 _`÷_
  infixl 4 _`+_
  infixl 4 _`-_

  --function which computes the value of an united-float-expression
  compute : {u : Units} → UF u → Float
  compute (V f _) = f
  compute (P f p _) = prefixed f p
  compute (x `+ x₁) = compute x f+ compute x₁
  compute (x `- x₁) = compute x f− compute x₁
  compute (x `× x₁) = compute x f× compute x₁
  compute (x `÷ x₁) = compute x f÷ compute x₁
--  compute (`√ x) = √ (compute x)

  --datatype for showint that two units are equivalent
  data Equivalent : Units → Units → Set where
    EqU : (u1 : Units) → (u2 : Units) → (order (reduce u1)) == (order (reduce u2)) → Equivalent u1 u2

  test-EqU : Equivalent ((U meter) u× (U meter-)) (U noU)
  test-EqU = EqU (U meter u× U meter-) (U noU) Refl

  postulate
    --proof that reduce u is in fact reduced
    reducedreduced : (u : Units) → reduce u == reduce (reduce u)
    --indirect proof that reduce u is in fact reduced
    ord-r-r :  (u : Units) → order-u noU
      (order-u meter
       (order-u mol-
        (order-u candela-
         (order-u kelvin-
          (order-u ampere-
           (order-u second-
            (order-u gram-
             (order-u meter-
              (order-u mol
               (order-u candela
                (order-u kelvin
                 (order-u ampere
                  (order-u second (order-u gram (reduce u)))))))))))))))
      ==
      order-u noU
      (order-u meter
       (order-u mol-
        (order-u candela-
         (order-u kelvin-
          (order-u ampere-
           (order-u second-
            (order-u gram-
             (order-u meter-
              (order-u mol
               (order-u candela
                (order-u kelvin
                 (order-u ampere
                  (order-u second (order-u gram (reduce (reduce u))))))))))))))))

  --proof that u is equivalent to reduce u
  reduced= : (u : Units) → Equivalent u (reduce u)
  reduced= u = EqU u (reduce u) (ord-r-r u) 



--------------------------------------------------------------------------------
------------ Library for example code ------------------------------------------
--------------------------------------------------------------------------------
  --NOTE: sin and cos are in radians!
  cos : UF (U noU) → UF (U noU)
  cos θ = V (primSin (primFloatMinus (primFloatDiv π 2.0) (compute θ))) (U noU)

  sin : UF (U noU) → UF (U noU)
  sin θ = V (primSin (compute θ)) (U noU)

  --gravitational constant on earth
  g : UF (order ((U meter) u× ((U second-) u× (U second-))))
  g = V (~ 9.8) ((U meter) u× ((U second-) u× (U second-)))

  --function which finds the distance a projectile will travel when launched 
  --  with a given initial velocity, launch angle, and gravitational constant. 
  --  (Assumes initial height is 0)
  proj-dist-trav : UF (order ((U meter) u× (U second-)))                  --velocity
                → UF (U noU)                                             --angle (in radians)
                → UF (order ((U meter) u× ((U second-) u× (U second-)))) -- gravitational constant
                → UF (U meter)                                           -- distance traveled
  proj-dist-trav v θ g = ((v `× cos θ) `÷ g) `× ((V 2.0 (U noU)) `× (v `× sin θ))

  --function which finds the maximum height of a projectile launched with a
  --  given initial velocity, launch angle, initial height, and gravitational 
  --  constant.
  proj-max-height : UF (order ((U meter) u× (U second-)))               --velocity
               → UF (U noU)                                             --angle (in radians)
               → UF (U meter)                                           -- initial height
               → UF (order ((U meter) u× ((U second-) u× (U second-)))) -- gravitational constant
               → UF (U meter)                                           -- maximum height
  proj-max-height v θ y₀ g = ((v `× v `× sin θ `× sin θ) `÷ ((V (~ 2.0) (U noU)) `× g)) `+ y₀

  --a few values for testing: max height of projectile launched up with initial
  --  velocity of 1 m/s
  h1ms : UF (U meter)
  h1ms = proj-max-height (V 1.0 ((U meter) u× (U second-))) (V (π f÷ 2.0) (U noU)) (V 0.0 (U meter)) g

  h1msf : Float
  h1msf = compute h1ms

  vtest : UF (order ((U meter) u× (U second-)))
  vtest = V 1.0 (U meter) `÷ V 1.0 (U second)
  v2test : UF (order (((U second-) u× (U second-)) u× ((U meter) u× (U meter))))
  v2test = vtest `× vtest
  gytest : UF (order ((U meter) u× (U meter) u× ((U second-) u× (U second-))))
  gytest = V 2.0 (U noU) `× V (~ 9.8) ((U meter) u× ((U second-) u× (U second-))) `× V 1.0 (U meter)
  v2gy : UF (order ((U meter) u× (U meter) u× ((U second-) u× (U second-))))
  v2gy = v2test `+ gytest
