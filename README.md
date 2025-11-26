# VKcurve
Fundamental group of the complement of a curve in the 2-dimensional complex space.

This  package is  a port  to Julia  of the  GAP3 package VKcurve written by
David Bessis and Jean Michel in 2002.

The  main function  computes the  fundamental group  of the complement of a
complex  algebraic curve in `ℂ²`, using an implementation of the Van Kampen
method; see for example

D.  Cheniot. "Une  démonstration du  théorème de  Zariski sur  les sections
hyperplanes  d'une hypersurface projective et du théorème de Van Kampen sur
le  groupe fondamental  du complémentaire  d'une courbe  projective plane."
Compositio Math., 27:141--158, 1973.

for a clear and modernized account of this method. Here is are examples for
curves defined as the zeros of two-variable polynomials in `x` and `y`.

```julia-repl
julia> using PuiseuxPolynomials, VKcurve

julia> @Mvp x,y

julia> fundamental_group(x^2-y^3)
Presentation: 2 generators, 1 relator, total length 6
1: bab=aba

julia> fundamental_group((x+y)*(x-y*im)*(x+2*y))
Presentation: 3 generators, 2 relators, total length 12
1: abc=bca
2: cab=abc
```

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jmichel7.github.io/VKcurve.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jmichel7.github.io/VKcurve.jl/dev/)
[![Build Status](https://github.com/jmichel7/VKcurve.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jmichel7/VKcurve.jl/actions/workflows/CI.yml?query=branch%3Amain)
