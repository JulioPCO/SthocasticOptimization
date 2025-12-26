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

#binarias de seleção de terreno

#binaria terreno 1
@variable(model, x[1:3, 1:4])

#binaria permite ou zera valor
@variable(model, b[1:3, 1:4],Bin)

#Inteira para problema
@variable(model, k[1:4, 1:3],Int)

# objective
@objective(model, Min, 150*(x[1,1] + x[1,2] + x[1,3] + x[1,4]) + 230*(x[2,1] + x[2,2] + x[2,3] + x[2,4]) + 260*(x[3,1] + x[3,2] + x[3,3] + x[3,4])
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
#@constraint(model, C_limita_espaco ,x1 + x2 + x3 <= 500)

limites = [185,145,105,65]
#Restrições terreno
@constraint(model, [i = 1:3, j = 1:4], x[i,j] <= limites[j]*b[i,j])

@constraint(model,  sum(b[i,1] for i in 1:3) <= 1)
@constraint(model,  sum(b[i,2] for i in 1:3) <= 1)
@constraint(model,  sum(b[i,3] for i in 1:3) <= 1)
@constraint(model,  sum(b[i,4] for i in 1:3) <= 1)

#Restrição Inteira Trigo
@constraint(model, y11==100*k[1,1])
@constraint(model, w11==100*k[2,1])

@constraint(model, y12==100*k[1,2])
@constraint(model, y12==100*k[2,2])

@constraint(model, y13==100*k[1,3])
@constraint(model, y13==100*k[2,3])

#Restrição Inteira Milho
@constraint(model, y21==100*k[3,1])
@constraint(model, w21==100*k[4,1])

@constraint(model, y22==100*k[3,2])
@constraint(model, y22==100*k[4,2])

@constraint(model, y23==100*k[3,3])
@constraint(model, y23==100*k[4,3])


#cenário 1
@constraint(model, C_preco_trigo_1,3*(x[1,1] + x[1,2] + x[1,3] + x[1,4]) + y11 - w11 >=200)
@constraint(model, C_preco_milho_1, 3.6*(x[2,1] + x[2,2] + x[2,3] + x[2,4]) + y21 - w21 >=240)
@constraint(model, C_preco_cana_1, w31 + w41 <= 24*(x[3,1] + x[3,2] + x[3,3] + x[3,4]))
@constraint(model, C_maximo_cana_cara_1, w31<= 6000)

#cenario 2
@constraint(model, C_preco_trigo_2,2.5*(x[1,1] + x[1,2] + x[1,3] + x[1,4]) + y12 - w12 >=200)
@constraint(model, C_preco_milho_2, 3*(x[2,1] + x[2,2] + x[2,3] + x[2,4])  + y22 - w22 >=240)
@constraint(model, C_preco_cana_2, w32 + w42 <= 20*(x[3,1] + x[3,2] + x[3,3] + x[3,4]))
@constraint(model, C_maximo_cana_cara_2, w32<= 6000)

# cenário 3
@constraint(model, C_preco_trigo_3,2*(x[1,1] + x[1,2] + x[1,3] + x[1,4]) + y13 - w13 >=200)
@constraint(model, C_preco_milho_3, 2.4*(x[2,1] + x[2,2] + x[2,3] + x[2,4])  + y23 - w23 >=240)
@constraint(model, C_preco_cana_3, w33 + w43 <= 16*(x[3,1] + x[3,2] + x[3,3] + x[3,4]))
@constraint(model, C_maximo_cana_cara_3, w33<= 6000)

#Optimize
optimize!(model)

#Teste
if !is_solved_and_feasible(model)
    @warn("The model was not solved correctly.")
    return
end

println("O valor esperado de lucro é de $(-objective_value(model))")

println("O valor de b $(value(b))")
println("O valor de x $(value(x))")
println("O valor de k $(value(k))")

# basicamente ele seleciona o melhor cenário produz 200 a mais de trigo e 100 a mais de milho para vender e o resto é cana. Os resultados fazem sentido na formulação dos cenários.