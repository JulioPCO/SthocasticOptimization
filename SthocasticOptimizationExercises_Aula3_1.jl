using JuMP
using HiGHS
using LinearAlgebra

alfa=0.1

S= ["Estado0","Estado1","Estado2",]
A= ["a0","a1"]

rec = [
    0  0; 
    0  0; 
    0 -1;;;
    0 0;
    5 0;
    0 0;;;
    0 0;
    0 0;
    0 0 
]


q = [0.5 0; # P(S0 | S0,a) 
0.7 0; # P(S0 | S1,a) 
0.4 0.3;;; # P(S0 | S2,a) 
0 0; # P(S1 | S0,a) 
0.1 0.95; # P(S1 | S1,a) 
0 0.3;;; # P(S1 | S2,a) 
0.5 1; # P(S2 | S0,a) 
0.2 0.05; # P(S2 | S1,a) 
0.6 0.4] # P(S2 | S2,a)


qs = Containers.DenseAxisArray(q, S, A, S)
recs = Containers.DenseAxisArray(rec, S, A, S)

r = zeros(Float64, 3, 2)

rs=Containers.DenseAxisArray(r,
 S,A)
for s in S, a in A, sp in S
    rs[sp,a] += alfa* qs[s,a,sp] * recs[s,a,sp]
end


m = Model(HiGHS.Optimizer)

@variable(m, x[S,A] >=0)

@objective(m,Max,sum(rs[s,a]*x[s,a] for s in S, a in A))
@constraint(m, restr[s in S], sum(x[s,a] for a in A) - alfa*sum(qs[i,a,s]*x[i,a] for i in S, a in A)==1)
 
# set_silent(m)
optimize!(m)


# println(termination_status(model))
println(m)

# Política ótima
println("x[s,a] otimo:")
for s in S, a in A
    println(s, ", ", a, " = ", value(x[s,a]))
end