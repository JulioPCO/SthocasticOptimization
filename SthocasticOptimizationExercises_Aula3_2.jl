using JuMP
using HiGHS
using LinearAlgebra

alfa=0.11

S= ["S1","S2","S3","S4","S5","S6","S7"]
A= ["a0","a1"]


q = [0.5 0.5; # P(S1 ) 
0 0.3; 
0 0;
0 0;
0 0;
0 0;
0 0;;; 
0.5 0;# P(S2 )
0.6 0;
0.3 0;
0.4 0;
0 0;
0 0;
0 0;;;
0 0.5;# P(S3 )
0 0.7;
0.6 0.5;
0 0;
0 0;
0 0;
0 0;;;
0 0;# P(S4 )
0 0;
0 0.5;
0.1 0;
0 0;
0.9 1;
0 0;;;
0 0;# P(S5 )
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;;;
0 0;# P(S6 )
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;;;
0 0;# P(S7 )
0 0;
0 0;
0 0;
0 0;
0 0;
0 0;;; 
] 

r = [0 0 ;
1 1;
-1 -1;
-10 -10;
-10 -10;
100 100
-1000 -1000;
]
qs = Containers.DenseAxisArray(q, S, A, S)

rs=Containers.DenseAxisArray(r,
 S,A)

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

s_validos = ["S1","S2","S3","S4"]
for s in S, a in A
    println(s, ", ", a, " = ", value(x[s,a]))
end