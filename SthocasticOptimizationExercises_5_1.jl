using JuMP
using HiGHS

model = Model(HiGHS.Optimizer)

# variables
@variable(model, x >= 0)
@variable(model, x1 >= 0)
@variable(model, x2 >= 0)
@variable(model, x3 >= 0)
# objective
@objective(model, Min, 0.33x1 + 0.33x2 + 0.33x3 )

#Restrições
@constraint(model, C_limita_espaco ,1-x <=x1)
@constraint(model, C_preco_tomate,2-x <=x2)
@constraint(model, C_preco_trigo, 4-x <=x3)
# @constraint(model, C_limita_espaco2 ,x-1 <=x1)
# @constraint(model, C_preco_tomate2,x-2 <=x2)
#Optimize
optimize!(model)

println("O valor de x $(value(x))")
println("O valor de z1 $(value(x1))")
println("O valor de z2 $(value(x2))")
println("O valor de z3 $(value(x3))")

model2 = Model(HiGHS.Optimizer)

# variables
@variable(model2, p)
# objective
@objective(model2, Max, -3p )

#Restrições
@constraint(model2, C_limita_espaco ,p<=1)
@constraint(model2, C_limita_espaco3 ,p<=-1)
optimize!(model2)

println("O valor de b $(value(p))")
