using JuMP
using HiGHS

model = Model(HiGHS.Optimizer)

# variables
@variable(model, x1 >= 0)
@variable(model, x2 >= 0)
@variable(model, x3 >= 0)
@variable(model, y1 >= 0)
@variable(model, y2 >= 0)
@variable(model, w1 >= 0)
@variable(model, w2 >= 0)
@variable(model, w3 >= 0)
@variable(model, w4 >= 0)

# objective
@objective(model, Min, 150x1 + 230x2 + 260x3 + 238y1 - 170w1 +210y2 - 150w2 - 36w3 - 10w4)

#Restrições
@constraint(model, C_limita_espaco ,x1 + x2 + x3 <= 500)
@constraint(model, C_preco_tomate,2.5x1 + y1 - w1 >=200)
@constraint(model, C_preco_trigo, 3x2 + y2 - w2 >=240)
@constraint(model, C_preco_cevada, w3 + w4 <= 20x3)
@constraint(model, C_maximo_cevada_cara, w3<= 6000)

#Optimize
optimize!(model)