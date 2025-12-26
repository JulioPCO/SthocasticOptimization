using JuMP
using HiGHS

model = Model(HiGHS.Optimizer)

#=
x1 = hectares dedicados ao trigo,
x2 = hectares dedicados ao milho,
x3 = hectares dedicados a cana-de-a¸c´ucar,
w1 = toneladas de trigo vendidas,
y1 = toneladas de trigo compradas,
w2 = toneladas de milho vendidas,
y2 = toneladas de milho compradas,
w3 = toneladas de cana-de-a¸c´ucar e
w4 = toneladas de cana-de-a¸c´ucar.
=#

# variables
@variable(model, x1 >= 0)
@variable(model, x2 >= 0)
@variable(model, x3 >= 0)
# cenario 1
@variable(model, y11 >= 0)
@variable(model, y21 >= 0)
@variable(model, w11 >= 0)
@variable(model, w21 >= 0)
@variable(model, w31 >= 0)
@variable(model, w41 >= 0)

#cenário 2
@variable(model, y12 >= 0)
@variable(model, y22 >= 0)
@variable(model, w12 >= 0)
@variable(model, w22 >= 0)
@variable(model, w32 >= 0)
@variable(model, w42 >= 0)

# cenário 3
@variable(model, y13 >= 0)
@variable(model, y23 >= 0)
@variable(model, w13 >= 0)
@variable(model, w23 >= 0)
@variable(model, w33 >= 0)
@variable(model, w43 >= 0)

# objective
@objective(model, Min, 150x1 + 230x2 + 260x3
         -1/3 *( 0.9*(-238y11 + 170w11) +
                 0.9*(-210y21 + 150w21) + 
                  1*(36w31 + 10w41) )
         -1/3 *( 1*(-238y12 + 170w12) +
                 1*(-210y22 + 150w22) + 
                  1*(36w32 + 10w42))
         -1/3 *( 1.1*(-238y13 + 170w13) +
                 1.1*(-210y23 + 150w23) + 
                  1*(36w33 + 10w43)
                  )
            )

#Restrições
@constraint(model, C_limita_espaco ,x1 + x2 + x3 <= 500)

#cenário 1
@constraint(model, C_preco_trigo_1,3x1 + y11 - w11 >=200)
@constraint(model, C_preco_milho_1, 3.6x2 + y21 - w21 >=240)
@constraint(model, C_preco_cana_1, w31 + w41 <= 24x3)
@constraint(model, C_maximo_cana_cara_1, w31<= 6000)

#cenario 2
@constraint(model, C_preco_trigo_2,2.5x1 + y12 - w12 >=200)
@constraint(model, C_preco_milho_2, 3x2 + y22 - w22 >=240)
@constraint(model, C_preco_cana_2, w32 + w42 <= 20x3)
@constraint(model, C_maximo_cana_cara_2, w32<= 6000)

# cenário 3
@constraint(model, C_preco_trigo_3,2x1 + y13 - w13 >=200)
@constraint(model, C_preco_milho_3, 2.4x2 + y23 - w23 >=240)
@constraint(model, C_preco_cana_3, w33 + w43 <= 16x3)
@constraint(model, C_maximo_cana_cara_3, w33<= 6000)

#Optimize
optimize!(model)

#Teste
if !is_solved_and_feasible(model)
    @warn("The model was not solved correctly.")
    return
end

println("O valor esperado de lucro é de $(-objective_value(model))")
println("O valor de w $(value([w11,w21,w31,w41,w12,w22,w32,w42,w13,w23,w33,w43]))")
println("O valor de y $(value([y11,y21,y12,y22,y13,y23]))")
