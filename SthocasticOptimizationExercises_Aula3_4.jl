using JuMP
using HiGHS

M=100

T=50

m = Model(HiGHS.Optimizer)
@variable(m,x[1:T] >= 0)


@objective(m, Min, sum(x[t]^2 for t in 1:T))

@constraint(m,sum(x[t] for t in 1:T)==M)

optimize!(m)

# println(termination_status(model))
println(m)

# Política ótima
println("x[s,a] otimo:")
println(objective_value(m))
print(value(x))