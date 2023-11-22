
<a id='VKcurve'></a>

<a id='VKcurve-1'></a>

# VKcurve

- [VKcurve](index.md#VKcurve)

<a id='VKcurve' href='#VKcurve'>#</a>
**`VKcurve`** &mdash; *Module*.



This is a port to Julia of the GAP3 package VKcurve written by David Bessis and Jean Michel in 2002.

The  main function  computes the  fundamental group  of the complement of a complex  algebraic curve in `ℂ²`, using an implementation of the Van Kampen method (see for example

D. Cheniot. "Une démonstration du théorème de   Zariski sur les sections hyperplanes d'une hypersurface projective et du   théorème de Van Kampen sur le groupe fondamental du   complémentaire d'une courbe projective plane." Compositio Math., 27:141–158, 1973.

for  a clear and modernized account of this method). Here is an example for curves given by the zeroes of two-variable polynomials in `x` and `y`.

```julia-rep1
julia> using Gapjm, VKcurve

julia> @Mvp x,y

julia> fundamental_group(x^2-y^3)
Presentation: 2 generators, 1 relator, total length 6
1: bab=aba

julia> fundamental_group((x+y)*(x-y*im)*(x+2*y))
Presentation: 3 generators, 2 relators, total length 12
1: abc=bca
2: cab=abc
```

Here  we define the variables and then  give the curves as argument. Though approximate  calculations are used  at various places,  they are controlled and  the final result is exact; technically speaking, the computations use `Rational{BigInt}` or `Complex{Rational{BigInt}}` since the precision given by  floats  in  unsufficient.  It  might  be  possible  to use intervals of bigfloats  to make faster  computations, but it  would make the programming more  difficult.  If  you  have  a  polynomial with float coefficients, you should convert the coefficients to `Complex{Rational{BigInt}}` (if they are of  any integer or rational type, or of type `Complex{<:Integer}` they will be converted internally to `Complex{Rational{BigInt}}`).

The  output  is  a  `struct`  which  contains lots of information about the computation,  including a  presentation of  the computed fundamental group, which is what is displayed by default when printing it.

Our  motivation  for  writing  this  package  in  2002 was to find explicit presentations  for  generalized  braid  groups  attached to certain complex reflection  groups. Though presentations  were known for  almost all cases, six  exceptional cases were missing (in the notations of Shephard and Todd, these  cases are  `G₂₄`, `G₂₇`,  `G₂₉`, `G₃₁`,  `G₃₃` and `G₃₄`). Since the existence of nice presentations for braid groups was proved (non-constructively) in

D. Bessis. "Zariski theorems and diagrams for braid groups.", Invent. Math. 145:487–507, 2001

it  was upsetting not to  know them explicitly. In  the absence of any good grip  on the  geometry of  these six  examples, brute force (using VKcurve) gave  us we  have obtained  presentations for  all of  them (they have been confirmed  by less computational methods  since). These computations can be reproduced by `fundamental_group(VKcurve.data[i])` where `i∈{23,24,27,29,31,33,34}`.

If  you  are  not  interested  in  the  details  of  the  algorithm, and if 'fundamental_group' as in the above examples gives you satisfactory answers in a reasonable time, then you do not need to read this manual any further.

To  implement the algorithms, we needed  to write auxiliary facilities, for instance  find  `Complex{Rational}`  approximations  of  zeros  of  complex polynomials,  or work  with piecewise  linear braids,  which may  be useful facilities  on their own. These are documented in this manual.

Before  discussing  our  actual  implementation,  let  us  give an informal summary  of the mathematical  background. Our strategy  is adapted from the one  originally described in the 1930's by Van Kampen. Let `C` be an affine algebraic  curve, given as the  set of zeros in  `ℂ²` of a non-zero reduced polynomial  `P(x,y)`.  The  problem  is  to  compute  a presentation of the fundamental  group of  `ℂ²-C`. Consider  `P` as  a polynomial  in `x`, with coefficients  in the ring  of polynomials in  `y`, that is `P=α₀(y)xⁿ+α₁(y) xⁿ⁻¹+…+αₙ₋₁(y)x+αₙ(y)`, where the `αᵢ∈ℂ[y]`. Let `Δ(y)` be the discriminant of  `P` or, in other words, the resultant  of `P` and `∂P/∂x`. Since `P` is reduced,  `Δ` is non-zero. Let `y₁,…,y_d` be the roots of the corresponding reduced polynomial `Δ_{red}`. For a generic value of `y`, the polynomial in `x`  given by  `P(x,y)` has  `n` distinct  roots. When  `y=yⱼ`, with `j` in `1,…,d`,  we  are  in  exactly  one  of  the  following  situations: either `P(x,yⱼ)=0`  (we then say that  `yⱼ` is bad), or  `P(x,yⱼ)` has a number of roots  in  `x`  strictly  smaller  than  `n`.  Fix  `y₀` in `ℂ-{y₁,…,y_d}`. Consider  the projection `p:  ℂ²→ ℂ, (x,y)↦  y`. It restricts  to a locally trivial  fibration with base space `B=ℂ-{y₁,…,y_d}` and fibers homeomorphic to  the complex plane with  `n` points removed. We  denote by `E` the total space `p⁻¹(B)` and by `F` the fiber over `y₀`. The fundamental group of `F` is  isomorphic to the free group on `n` generators. Let `γ₁,…,γ_d` be loops in  the  pointed  space  `(B,y₀)`  representing  a  generating  system  for `π₁(B,y₀)`.  By trivializing  the pullback  of `p`  along `γᵢ`,  one gets a (well-defined  up to  isotopy) homeomorphism  of `F`,  and a (well-defined) automorphism `φᵢ` of the fundamental group of `F`, identified with the free group `Fₙ` by the choice of a generating system `f₁,…,fₙ`. An effective way of  computing `φᵢ` is by following the solutions in `x` of `P(x,y)=0`, when `y`  moves along `φᵢ`. This defines a loop in the space of configuration of `n`  points in a plane, hence an element  `bᵢ` of the braid group `Bₙ` (via an  identification of `Bₙ` with the fundamental group of this configuration space).  Let `φ` be the Hurwitz action of  `Bₙ` on `Fₙ`. All choices can be made in such a way that `φᵢ=φ(bᵢ)`. The theorem of Van Kampen asserts that, if  there are  no bad  roots of  the discriminant,  a presentation  for the fundamental group of `ℂ²-C` is `⟨f₁,…,fₙ∣∀i,j,φᵢ(fⱼ)=fⱼ⟩`. A variant of the above presentation (see 'VKquotient') can be used to deal with bad roots of the discriminant.

This algorithm is implemented in the following way.

  * As input, we have a polynomial `P`. We reduce `P` if it was not.
  * The discriminant `Δ` of `P` with respect to `x`, a polynomial in `y`, is computed.
  * The  roots  of  `Δ`  are  approximated,  via  the  following procedure. First,  we reduce `Δ` and get  `Δ_{red}` (generating the radical of the ideal  generated  by  `Δ`).  The  roots  `{y₁,…,y_d}`  of `Δ_{red}` are separated   by  'separate_roots'   (which  uses   Newton's  method  and continuous fraction aprroximations).
  * Loops around  these roots  are computed  by 'loops*around*punctures'. This  function first computes  some sort of  honeycomb, consisting of a set  `S` of  affine segments,  isolating the  `yᵢ`. Since  it makes the computation  of the monodromy  more effective, each  inner segment is a fragment  of the mediatrix of two roots of `Δ`. Then a vertex of one of the  segments is chosen as a basepoint, and the function returns a list of  lists of oriented segments  in `S`: each list of segments encodes a piecewise linear loop `γᵢ` circling one of `yᵢ`.
  * For each  segment in  `S`, we  compute the  monodromy braid obtained by following  the solutions in `x` of  `P(x,y)=0` when `y` moves along the segment. By default, this monodromy braid is computed by `follow_monodromy`. The strategy is to compute a piecewise-linear braid approximating  the actual monodromy geometric braid. The approximations are controlled. The piecewise-linear braid is constructed step-by-step, by  computations of linear pieces. As soon as new piece is constructed, it  is converted  into an  element of  `Bₙ` and  multiplied; therefore, though  the braid may consist of a  huge number of pieces, the function `follow_monodromy`   works  with  constant  memory.  The  package  also contains  a variant  `approx_follow_monodromy`, which  runs faster, but without guarantee on the result (see below).
  * The monodromy braids `bᵢ` corresponding  to the loops `γᵢ` are obtained by  multiplying the monodromy braids  of the correponding segments. The action  of these elements of `Bₙ` on the free group `Fₙ` is computed by 'hurwitz'  and the resulting  presentation of the  fundamental group is computed  by 'VKquotient'. It happens for  some large problems that the whole process fails here, because the braids `bᵢ` obtained are too long and  the  computation  of  the  action  on  `Fₙ` requires thus too much memory.  We have been  able to solve  such problems when  they occur by calling  at  this  stage  our  function  'shrink'  which  finds smaller generators  for the  subgroup of  `Bₙ` generated  by the  `bᵢ` (see the description  in `Gapjm.Garside`). This function is called if 'VK.shrinkBraid==true'.
  * Finally, the presentation is simplified by 'simplify'. This function is a   heuristic   function   for   simplifying   presentations.   It   is non-deterministic.

From  the algorithmic point of view, memory should not be an issue, but the procedure  may  take  a  lot  of  CPU  time  (the  critical  part being the computation  of the monodromy braids  by 'follow*monodromy'). For instance, an  empirical study with  the curves `x²-yⁿ`  suggests that the needed time grows  exponentially with `n`.  The variable `VK.approx*monodromy`controls which  monodromy function  is used.  The default  value of this variable is`false`,  which means that`follow*monodromy`will be used. If the variable is  set to`true`then`approx*follow*monodromy`will  be used, where the approximations  are no longer  controlled. Therefore presentations obtained while`VK.approx*monodromy`is set  to 'true' are  not certified. However, though it is likely that there exists examples for which`approx*follow*monodromy` actually returns incorrect answers, we still have not seen one.


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L1-L172' class='documenter-source'>source</a><br>

<a id='Gapjm.Semisimple.fundamental_group-Tuple{Mvp}' href='#Gapjm.Semisimple.fundamental_group-Tuple{Mvp}'>#</a>
**`Gapjm.Semisimple.fundamental_group`** &mdash; *Method*.



`fundamental_group(curve::Mvp; verbose=0)`

`curve` should be an `Mvp` in `x` and `y` representing an equation `f(x,y)` for  a  curve  in  `ℂ²`.  The  coefficients  should be integers, rationals, gaussian  integers or  gaussian rationals.  The result  is a  record with a certain number of fields which record steps in the computation described in this introduction:

```julia-repl
julia> @Mvp x,y

julia> r=fundamental_group(x^2-y^3)
Presentation: 2 generators, 1 relator, total length 6
1: bab=aba

julia> propertynames(r)
(:curve, :ismonic, :prop, :rawPresentation, :B, :basepoint, :dispersal, :monodromy, :discyFactored, :segments, :braids, :roots, :nonVerticalPart, :discy, :zeros, :curveVerticalPart, :points, :loops, :presentation)

julia> r.curve # the given equation
Mvp{Rational{BigInt}}: (1//1)x²+(-1//1)y³

julia> Pol(:y);r.discy # its discriminant wrt x
Pol{Rational{BigInt}}: (1//1)y

julia> r.roots  # roots of the discriminant
1-element Vector{Rational{BigInt}}:
 0//1

julia> r.points # for points, segments and loops see loops_around_punctures
4-element Vector{Complex{Rational{BigInt}}}:
  0//1 - 1//1*im
 -1//1 + 0//1*im
  1//1 + 0//1*im
  0//1 + 1//1*im

julia> r.segments
4-element Vector{Vector{Int64}}:
 [1, 2]
 [1, 3]
 [2, 4]
 [3, 4]

julia> r.loops
1-element Vector{Vector{Int64}}:
 [4, -3, -1, 2]

julia> r.zeros # zeroes of curve(y=pt) when pt runs over r.points
4-element Vector{Vector{Complex{Rational{BigInt}}}}:
 [5741//8119 + 5741//8119*im, -5741//8119 - 5741//8119*im]
 [0//1 + 1//1*im, 0//1 - 1//1*im]
 [1//1 + 0//1*im, -1//1 + 0//1*im]
 [-5741//8119 + 5741//8119*im, 5741//8119 - 5741//8119*im]

julia> r.monodromy # monodromy around each r.segment
4-element Vector{GarsideElt{Perm{Int16}, BraidMonoid{Perm{Int16}, CoxSym{Int16}}}}:
 (Δ)⁻¹
 Δ
 .
 Δ

julia> r.braids # monodromy around each r.loop
1-element Vector{GarsideElt{Perm{Int16}, BraidMonoid{Perm{Int16}, CoxSym{Int16}}}}:
 Δ³
```

```julia-rep1
julia> display_balanced(r.presentation) # printing of r by default
1: bab=aba
```

The  keyword argument `verbose` triggers the  display of information on the progress of the computation. It is recommended to set it at 1 or 2 when the computation seems to take a long time without doing anything. `verbose` set at  0 is the default and prints nothing; set at 1 it shows which segment is currently  active,  and  set  at  2  it  traces the computation inside each segment.

```julia-rep1
julia> fundamental_group(x^2-y^3,verbose=1);
# There are 4 segments in 1 loops
# follow_monodromy along segment 1/4  in   8 steps/  0.012sec got B(-1)
# follow_monodromy along segment 2/4  in   8 steps/ 0.00752sec got B(1)
# follow_monodromy along segment 3/4  in   8 steps/ 0.00557sec got B()
# follow_monodromy along segment 4/4  in   8 steps/ 0.00457sec got B(1)
# Computing monodromy braids along loops
[r.B(1,1,1),]
#I total length 3 maximal length 3

Presentation: 2 generators, 1 relator, total length 6
```


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L252-L340' class='documenter-source'>source</a><br>

<a id='VKcurve.simp' href='#VKcurve.simp'>#</a>
**`VKcurve.simp`** &mdash; *Function*.



`VKcurve.simp(t::Real;prec=10^-15,type=BigInt)`

simplest fraction of type `Rational{T}` approximating `t` closer than prec.

```julia-repl
julia> VKcurve.simp(float(π);prec=10^-6)
355//113
```


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L509-L517' class='documenter-source'>source</a><br>

<a id='VKcurve.NewtonRoot' href='#VKcurve.NewtonRoot'>#</a>
**`VKcurve.NewtonRoot`** &mdash; *Function*.



`VKcurve.NewtonRoot(p::Pol,initial_guess,precision::Real;showall=false,show=false,lim=800)`

Here   `p`  is   a  polynomial   with  `Rational`   or  `Complex{Rational}` coefficients.  The function  computes an  approximation to  a root  of `p`, guaranteed of distance closer than `precision` to an actual root. The first approximation  used is `initial`.  A possibility is  that the Newton method starting  from `initial` does not converge  (the number of iterations after which  this is decided  is controlled by  `lim`); then the function returns `nothing`.  Otherwise the function returns a pair: the approximation found, and an upper bound on the distance between that approximation and an actual root.  The point of returning  an upper bound is  that it is usually better than the asked-for `precision`. For the precision estimate a good reference is

J.  Hubbard, D. Schleicher,  and S. Sutherland.  "How to find  all roots of complex polynomials by Newton's method.", Invent. Math. 146:1–33, 2001.

```julia-repl
julia> p=Pol([1,0,1])
Pol{Int64}: y²+1

julia> VKcurve.NewtonRoot(p,1+im,10^-7)
(0//1 + 1//1*im, 3.3333333333333337e-10)
```

```julia-rep1
julia> VKcurve.NewtonRoot(p,1,10^-7;show=true)
****** Non-Convergent Newton after 800 iterations ******
p=y²+1 initial=-1.0 prec=1.0000000000000004e-7
```


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L536-L566' class='documenter-source'>source</a><br>

<a id='VKcurve.separate_roots' href='#VKcurve.separate_roots'>#</a>
**`VKcurve.separate_roots`** &mdash; *Function*.



`VKcurve.separate_roots(p::Pol, safety)`

Here  `p` is  a complex  polynomial. The  result is  a list  `l` of complex numbers  representing approximations to the roots  of `p`, such that if `d` is  the minimum distance between two elements  of `l`, then there is a root of  `p` within  radius `d/(2*safety)`  of any  element of  `l`. This is not possible when `p` has multiple roots, in which case `nothing` is returned.

```julia-repl
julia> @Pol q
Pol{Int64}: q

julia> VKcurve.separate_roots(q^2+1,100)
2-element Vector{Complex{Rational{BigInt}}}:
 0//1 + 1//1*im
 0//1 - 1//1*im

julia> VKcurve.separate_roots((q-1)^2,100)

julia> VKcurve.separate_roots(q^3-1,100)
3-element Vector{Complex{Rational{BigInt}}}:
 -1//2 - 181//209*im
  1//1 + 0//1*im
 -1//2 + 181//209*im
```


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L630-L656' class='documenter-source'>source</a><br>

<a id='VKcurve.find_roots' href='#VKcurve.find_roots'>#</a>
**`VKcurve.find_roots`** &mdash; *Function*.



`VKcurve.find_roots(p::Pol, approx)`

`p`  should have rational or  `Complex{Rational} coefficients. The function returns  'Complex' rational  approximations to  the roots  of`p`which are better  than`approx`(a  positive  rational).  Contrary to the functions`separate_roots`,  etc... described in the  previous chapter, this function handles  quite  well  polynomials  with  multiple  roots.  We  rely  on the algorithms explained in detail in cite{HSS01}.

```julia-repl
julia> VKcurve.find_roots((Pol()-1)^5,1/1000)
5-element Vector{Complex{Rational{BigInt}}}:
 1//1 + 0//1*im
 1//1 + 0//1*im
 1//1 + 0//1*im
 1//1 + 0//1*im
 1//1 + 0//1*im

julia> l=VKcurve.find_roots(Pol()^3-1,10^-5)
3-element Vector{Complex{Rational{BigInt}}}:
 -1//2 - 16296//18817*im
  1//1 + 0//1*im
 -1//2 + 16296//18817*im

julia> round.(Complex{Float64}.(l.^3);sigdigits=3)
3-element Vector{ComplexF64}:
 1.0 - 1.83e-9im
 1.0 + 0.0im
 1.0 + 1.83e-9im
```


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L683-L714' class='documenter-source'>source</a><br>

<a id='VKcurve.nearest_pair' href='#VKcurve.nearest_pair'>#</a>
**`VKcurve.nearest_pair`** &mdash; *Function*.



`VKcurve.nearest_pair(v::Vector{<:Complex})`

returns  a pair whose first element is the minimum distance (in the complex plane)  between two elements  of `v`, and  the second is  a pair of indices `[i,j]` such that `v[i],v[j]` achieves this minimum.

julia> nearest_pair([1+im,0,1]) 1=>[1,3]


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L176-L185' class='documenter-source'>source</a><br>

<a id='VKcurve.dist_seg' href='#VKcurve.dist_seg'>#</a>
**`VKcurve.dist_seg`** &mdash; *Function*.



`dist_seg(z,a,b)` distance (in the complex plane) of `z` to segment `[a,b]` 


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L192' class='documenter-source'>source</a><br>

<a id='VKcurve.loops_around_punctures' href='#VKcurve.loops_around_punctures'>#</a>
**`VKcurve.loops_around_punctures`** &mdash; *Function*.



`VKcurve.loops_around_punctures(points)`

`points`  should  be  a  list  of  complex  numbers.  The function computes piecewise-linear  loops representing generators of the fundamental group of `ℂ -{points}`.

```julia-repl
julia> VKcurve.loops_around_punctures([0])
1-element Vector{Vector{Complex{Int64}}}:
 [1 + 0im, 0 + 1im, -1 + 0im, 0 - 1im, 1 + 0im]
```

Guarantees on the result: for  a set `Z` of zeroes and `z∈Z`, let `R(z):=dist(z,Z-z)/2`. The input of `points`  is a set `Z` of approximate zeroes of `r.discy` such that for any `z`  one  of  the  zeroes  is  closer  than  `R(z)/S` where `S` is a global constant   of  the  program   (in  practice  we   may  take  `S=100`).  Let `d=inf_{z∈Z}(R(z))`;   we  return   points  with   denominator  `10^-k`  or `10^-k<d/S'` (in practive we take `S'=100`) and such that the distance of a segment to a zero of `r.discy` is guaranteed `>= d-d/S'-d/S`.


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L877-L897' class='documenter-source'>source</a><br>

<a id='VKcurve.convert_loops' href='#VKcurve.convert_loops'>#</a>
**`VKcurve.convert_loops`** &mdash; *Function*.



`VKcurve.convert_loops(ll)`

The  input is a list  of loops, each a  list of complex numbers representing the vertices of the loop.

The output is a named tuple with fields

  * `points`: a list of complex  numbers.
  * `segments`:  a list of oriented segments, each of them  encoded by the list of the positions in 'points' of  its two endpoints.
  * `loops`: a list of loops. Each loops is a list  of integers representing a  piecewise  linear  loop,  obtained  by  concatenating the `segments` indexed  by the  integers, where  a negative  integer is  used when the opposed orientation of the segment is taken.


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L827-L841' class='documenter-source'>source</a><br>

<a id='VKcurve.follow_monodromy' href='#VKcurve.follow_monodromy'>#</a>
**`VKcurve.follow_monodromy`** &mdash; *Function*.



`VKcurve.follow_monodromy(r,segno)` This  function computes the  monodromy braid of  the solution in  `x` of an equation   `P(x,y)=0`  along   a  segment   `[y₀,y₁]`.  It   is  called  by `fundamental_group`  for each  segment in  turn. The  first argument is the record containing intermediate information computed by `fundamental_group`. The second argument is the index of the segment in `r.segments`.

The function returns an element of the ambient braid group `r.B`.

This function has no reason to be called directly by the user, so we do not illustrate  its behavior. Instead,  we explain what  is displayed on screen when the user sets `verbose=2`.

What is quoted below is an excerpt of what is printed during the execution of

```julia_rep1
julia> fundamental_group((x+3*y)*(x+y-1)*(x-y),verbose=2)
......
segment 1/16 step   1 time=0           ?2?1?3
segment 1/16 step   2 time=0.2         R2. ?3
segment 1/16 step   3 time=0.48        R2. ?2
segment 1/16 step   4 time=0.74        ?2R1?2
segment 1/16 step   5 time=0.94        R1. ?2
======================================
==    Nontrivial braiding B(2)      ==
======================================
segment 1/16 step   6 time=0.bc        R1. ?1
segment 1/16 step   7 time=0.d8        . ?0. 
segment 1/16 step   8 time=0.dc        ?1R0?1
# follow_monodromy(segment 1/16) in   8 steps/ 0.0209sec got B(2)
```

`follow_monodromy`  computes its  results by  subdividing the  segment into smaller  subsegments on which the  approximations are controlled. It starts at  one end and moves subsegment after  subsegment. A new line is displayed at each step.

The  first column indicates which segment  is studied. The second column is the  number of iterations  so far (number  of subsegments). In our example, `follow_monodromy`  had  to  cut  the  segment  into  `8` subsegments. Each subsegment  has its own length. The cumulative length at a given step, as a fraction  of the total  length of the  segment, is displayed after `time=`. This  gives a rough  indication of the  time left before  completion of the computation of the monodromy of this segment. The segment is completed when this fraction reaches `1`.

The  last column has  to do with  the piecewise-linear approximation of the geometric  monodromy  braid.  It  is  subdivided  into sub-columns for each string.  In the example above, there are  three strings. At each step, some strings are fixed (they are indicated by `.` in the corresponding column). A  symbol like `R5` or `?3` indicates  that the string is moving. The exact meaning   of  the  symbol  has  to   do  with  the  complexity  of  certain sub-computations.

As  some strings are moving, it  happens that their real projections cross. When  such a crossing occurs, it  is detected and the corresponding element of  `Bₙ` is displayed (`Nontrivial braiding  =`...). The monodromy braid is the  product of these  elements of `Bₙ`,  multiplied in the  order in which they occur.


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L1258-L1316' class='documenter-source'>source</a><br>

<a id='VKcurve.approx_follow_monodromy' href='#VKcurve.approx_follow_monodromy'>#</a>
**`VKcurve.approx_follow_monodromy`** &mdash; *Function*.



`VKcurve.approx_follow_monodromy(<r>,<segno>,<pr>)`

This function  computes an approximation  of the monodromy braid  of the solution in `x`  of an equation `P(x,y)=0` along  a segment `[y₀,y₁]`. It is called  by `fundamental_group`, once for each of  the segments. The first  argument is  a  global record,  similar to  the  one produced  by `fundamental_group`  (see the  documentation of  this function)  but only containing intermediate information. The second argument is the position of the segment in `r.segments`. 

Contrary  to `follow_monodromy`, `approx_follow_monodromy` does not control the approximations; it just uses a heuristic for how much to move along the segment  between linear braid computations, and this heuristic may possibly fail.  However, we have  not yet found  an example for  which the result is actually  incorrect, and thus  the existence is  justified by the fact that for  some difficult  computations, it  is sometimes  many times faster than `follow_monodromy`. We illustrate its typical output when `verbose=2`:

```julia-rep1
julia> VK.approx_monodromy=true

julia> fundamental_group((x+3*y)*(x+y-1)*(x-y);verbose=2)

  ....

546 ***rejected
447<15/16>mindist=2.55 step=0.5 total=0 logdisc=0.55 ***rejected
435<15/16>mindist=2.55 step=0.25 total=0 logdisc=0.455 ***rejected
334<15/16>mindist=2.55 step=0.125 total=0 logdisc=0.412 ***rejected
334<15/16>mindist=2.55 step=0.0625 total=0 logdisc=0.393
334<15/16>mindist=2.55 step=0.0625 total=0.0625 logdisc=0.412
334<15/16>mindist=2.56 step=0.0625 total=0.125 logdisc=0.433
334<15/16>mindist=2.57 step=0.0625 total=0.1875 logdisc=0.455
334<15/16>mindist=2.58 step=0.0625 total=0.25 logdisc=0.477
======================================
==    Nontrivial braiding B(2)      ==
======================================
334<15/16>mindist=2.6 step=0.0625 total=0.3125 logdisc=0.501
334<15/16>mindist=2.63 step=0.0625 total=0.375 logdisc=0.525
334<15/16>mindist=2.66 step=0.0625 total=0.4375 logdisc=0.55
334<15/16>mindist=2.69 step=0.0625 total=0.5 logdisc=0.576
334<15/16>mindist=2.72 step=0.0625 total=0.5625 logdisc=0.602
334<15/16>mindist=2.76 step=0.0625 total=0.625 logdisc=0.628
334<15/16>mindist=2.8 step=0.0625 total=0.6875 logdisc=0.655
334<15/16>mindist=2.85 step=0.0625 total=0.75 logdisc=0.682
334<15/16>mindist=2.9 step=0.0625 total=0.8125 logdisc=0.709
334<15/16>mindist=2.95 step=0.0625 total=0.875 logdisc=0.736
334<15/16>mindist=3.01 step=0.0625 total=0.9375 logdisc=0.764
# Minimal distance==2.55
# Minimal step==0.0625==-0.0521 + 0.0104im
# Adaptivity==10
monodromy[15]=[2]

# segment 15/16 Time==0.002741098403930664sec
```

Here  at each step the following  information is displayed: first, how many iterations  of the Newton  method were necessary  to compute each  of the 3 roots  of the current polynomial  `f(x,y₀)` if we are  looking at the point `y₀` of the segment. Then, which segment we are dealing with (here the 15th of  16 in all).  Then the minimum  distance between two  roots of `f(x,y₀)` (used  in our heuristic). Then the current  step in fractions of the length of  the segment we are looking at, and the total fraction of the segment we have  done. Finally,  the decimal  logarithm of  the absolute  value of the discriminant  at the  current point  (used in  the heuristic).  Finally, an indication  if  the  heuristic  predicts  that  we  should  halve  the step `***rejected` or that we may double it `***up`.

The function returns an element of the ambient braid group `r.B`.


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L1025-L1095' class='documenter-source'>source</a><br>

<a id='VKcurve.Lbraid2braid' href='#VKcurve.Lbraid2braid'>#</a>
**`VKcurve.Lbraid2braid`** &mdash; *Function*.



`VKcurve.Lbraid2braid(v1,v2,B)`

This function converts  the linear braid joining the points in `v1` to the corresponding ones in `v2` into an element of the braid group.

```julia-repl
julia> B=BraidMonoid(coxsym(3))
BraidMonoid(𝔖 ₃)

julia> VKcurve.Lbraid2braid([1+im,2+im,3+im],[2+im,1+2im,4-6im],B)
1
```

The lists `v1` and `v2` must have the same length, say `n`. Then `B` should be  `BraidMonoid(coxsym(n))`, the braid group  on `n` strings. The elements of  `v1` (resp. `v2`)  should be `n`  distinct complex rational numbers. We use the Brieskorn basepoint, namely the contractible set `C+iV_ℝ` where `C` is  a real chamber; therefore the endpoints  need not be equal. The strings defined  by `v1` and `v2` should be  non-crossing. When the numbers in `v1` (resp.  `v2`)  have  distinct  real  parts,  the  real picture of the braid defines a unique element of `B`. When some real parts are equal, we apply a lexicographical  desingularization, corresponding to a rotation of `v1` and `v2` by an arbitrary small positive angle.


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L1419-L1442' class='documenter-source'>source</a><br>

<a id='VKcurve.VKquotient' href='#VKcurve.VKquotient'>#</a>
**`VKcurve.VKquotient`** &mdash; *Function*.



`VKcurve.VKquotient(braids)`

The  input `braids` is a list `b₁,…,bn`, living in the braid group on `m` strings. Each `bᵢ` defines by Hurwitz action an automorphism `φᵢ` of the free group `Fₙ`. The function returns the group defined by the abstract presentation: $< f₁,…,fₙ ∣ ∀ i,j φᵢ(fⱼ)=fⱼ >$

```julia-repl
julia> B=BraidMonoid(coxsym(3))
BraidMonoid(𝔖 ₃)

julia> g=VKcurve.VKquotient([B(1,1,1),B(2)])
FreeGroup(a,b,c)/[b⁻¹a⁻¹baba⁻¹,b⁻¹a⁻¹b⁻¹aba,.,.,cb⁻¹,c⁻¹b]

julia> p=Presentation(g)
Presentation: 3 generators, 4 relators, total length 16
```

```julia-rep1
julia> display_balanced(p)
1: c=b
2: b=c
3: bab=aba
4: aba=bab

julia> simplify(p)
Presentation: 2 generators, 1 relator, total length 6
Presentation: 2 generators, 1 relator, total length 6

julia> display_balanced(p)
1: bab=aba
```


<a target='_blank' href='https://github.com/jmichel7/VKcurve.jl/blob/345a0731f20b7bb60137c26da2bcfd3dd983de96/src/VKcurve.jl#L1500-L1533' class='documenter-source'>source</a><br>

