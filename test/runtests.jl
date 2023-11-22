# auto-generated tests from julia-repl docstrings
using Test, Gapjm, VKcurve
function mytest(file::String,cmd::String,man::String)
  println(file," ",cmd)
  exec=repr(MIME("text/plain"),eval(Meta.parse(cmd)),context=:limit=>true)
  if endswith(cmd,";") exec="nothing" 
  else exec=replace(exec,r"\s*$"m=>"")
       exec=replace(exec,r"\s*$"s=>"")
  end
  if exec!=man 
    i=1
    while i<=lastindex(exec) && i<=lastindex(man) && exec[i]==man[i]
      i=nextind(exec,i)
    end
    print("exec=$(repr(exec[i:end]))\nmanl=$(repr(man[i:end]))\n")
  end
  exec==man
end
@testset "VKcurve.jl" begin
@test mytest("VKcurve.jl","@Mvp x,y","nothing")
@test mytest("VKcurve.jl","r=fundamental_group(x^2-y^3)","Presentation: 2 generators, 1 relator, total length 6\n1: bab=aba")
@test mytest("VKcurve.jl","propertynames(r)","(:curve, :ismonic, :prop, :rawPresentation, :B, :basepoint, :dispersal, :monodromy, :discyFactored, :segments, :braids, :roots, :nonVerticalPart, :discy, :zeros, :curveVerticalPart, :points, :loops, :presentation)")
@test mytest("VKcurve.jl","r.curve","Mvp{Rational{BigInt}}: (1//1)x²+(-1//1)y³")
@test mytest("VKcurve.jl","Pol(:y);r.discy","Pol{Rational{BigInt}}: (1//1)y")
@test mytest("VKcurve.jl","r.roots","1-element Vector{Rational{BigInt}}:\n 0//1")
@test mytest("VKcurve.jl","r.points","4-element Vector{Complex{Rational{BigInt}}}:\n  0//1 - 1//1*im\n -1//1 + 0//1*im\n  1//1 + 0//1*im\n  0//1 + 1//1*im")
@test mytest("VKcurve.jl","r.segments","4-element Vector{Vector{Int64}}:\n [1, 2]\n [1, 3]\n [2, 4]\n [3, 4]")
@test mytest("VKcurve.jl","r.loops","1-element Vector{Vector{Int64}}:\n [4, -3, -1, 2]")
@test mytest("VKcurve.jl","r.zeros","4-element Vector{Vector{Complex{Rational{BigInt}}}}:\n [5741//8119 + 5741//8119*im, -5741//8119 - 5741//8119*im]\n [0//1 + 1//1*im, 0//1 - 1//1*im]\n [1//1 + 0//1*im, -1//1 + 0//1*im]\n [-5741//8119 + 5741//8119*im, 5741//8119 - 5741//8119*im]")
@test mytest("VKcurve.jl","r.monodromy","4-element Vector{GarsideElt{Perm{Int16}, BraidMonoid{Perm{Int16}, CoxSym{Int16}}}}:\n (Δ)⁻¹\n Δ\n .\n Δ")
@test mytest("VKcurve.jl","r.braids","1-element Vector{GarsideElt{Perm{Int16}, BraidMonoid{Perm{Int16}, CoxSym{Int16}}}}:\n Δ³")
@test mytest("VKcurve.jl","VKcurve.simp(float(π);prec=10^-6)","355//113")
@test mytest("VKcurve.jl","p=Pol([1,0,1])","Pol{Int64}: y²+1")
@test mytest("VKcurve.jl","VKcurve.NewtonRoot(p,1+im,10^-7)","(0//1 + 1//1*im, 3.3333333333333337e-10)")
@test mytest("VKcurve.jl","p=Pol([1,0,1])","Pol{Int64}: y²+1")
@test mytest("VKcurve.jl","VKcurve.separate_roots_initial_guess(p,[1+im,1-im],10^5)","2-element Vector{Complex{Rational{BigInt}}}:\n 0//1 + 1//1*im\n 0//1 - 1//1*im")
@test mytest("VKcurve.jl","@Pol q","Pol{Int64}: q")
@test mytest("VKcurve.jl","VKcurve.separate_roots(q^2+1,100)","2-element Vector{Complex{Rational{BigInt}}}:\n 0//1 + 1//1*im\n 0//1 - 1//1*im")
@test mytest("VKcurve.jl","VKcurve.separate_roots((q-1)^2,100)","nothing")
@test mytest("VKcurve.jl","VKcurve.separate_roots(q^3-1,100)","3-element Vector{Complex{Rational{BigInt}}}:\n -1//2 - 181//209*im\n  1//1 + 0//1*im\n -1//2 + 181//209*im")
@test mytest("VKcurve.jl","VKcurve.find_roots((Pol()-1)^5,1/1000)","5-element Vector{Complex{Rational{BigInt}}}:\n 1//1 + 0//1*im\n 1//1 + 0//1*im\n 1//1 + 0//1*im\n 1//1 + 0//1*im\n 1//1 + 0//1*im")
@test mytest("VKcurve.jl","l=VKcurve.find_roots(Pol()^3-1,10^-5)","3-element Vector{Complex{Rational{BigInt}}}:\n -1//2 - 16296//18817*im\n  1//1 + 0//1*im\n -1//2 + 16296//18817*im")
@test mytest("VKcurve.jl","round.(Complex{Float64}.(l.^3);sigdigits=3)","3-element Vector{ComplexF64}:\n 1.0 - 1.83e-9im\n 1.0 + 0.0im\n 1.0 + 1.83e-9im")
@test mytest("VKcurve.jl","VKcurve.loops_around_punctures([0])","1-element Vector{Vector{Complex{Int64}}}:\n [1 + 0im, 0 + 1im, -1 + 0im, 0 - 1im, 1 + 0im]")
@test mytest("VKcurve.jl","B=BraidMonoid(coxsym(3))","BraidMonoid(𝔖 ₃)")
@test mytest("VKcurve.jl","VKcurve.Lbraid2braid([1+im,2+im,3+im],[2+im,1+2im,4-6im],B)","1")
@test mytest("VKcurve.jl","B=BraidMonoid(coxsym(3))","BraidMonoid(𝔖 ₃)")
@test mytest("VKcurve.jl","g=VKcurve.VKquotient([B(1,1,1),B(2)])","FreeGroup(a,b,c)/[b⁻¹a⁻¹baba⁻¹,b⁻¹a⁻¹b⁻¹aba,.,.,cb⁻¹,c⁻¹b]")
@test mytest("VKcurve.jl","p=Presentation(g)","Presentation: 3 generators, 4 relators, total length 16")
end
