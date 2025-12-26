
using Pkg
Pkg.activate(".")

using JuMP
using HiGHS
using Distributions
using Plots



n_cenarios = 1000

tempo = []
valor = []
id = []
plt = plot(title="Ex 1 - resultado",legend=false,marker=2)
plt2 = plot(title="Ex 1 - tempo",legend=false,marker=2)


p = ones(n_cenarios,n_cenarios)*1/n_cenarios

q = rand(Uniform(80,150),n_cenarios) 
d = rand(Uniform(300,500),n_cenarios) 

for k in  1:998:n_cenarios
    model = Model(HiGHS.Optimizer)
    set_silent(model)
    
    @variable(model, x >= 0)
    @variable(model, y[1:k, 1:k] >= 0)

    @objective(model, Min,  sum(p[i,j]*(100*x + q[i]*y[i,j]) for i in 1:k, j in 1:k))
                
    @constraint(model, [i=1:k,j=1:k], x + y[i,j]  >= d[j])

    @constraint(model, x<=350)
    #Optimize
    print(k)
    set_optimizer_attribute(model,"output_flag",false)
    optimize!(model)

    append!(id,k)
    append!(tempo,solve_time(model))

    append!(valor,value(x))

    #push!(plt,i,valor[i])
    #push!(plt2,i,tempo[i])
end

p1 = plot(id,valor,title="Valor x", legend=false)
p2 = plot(id,tempo,title="Tempo", legend=false)

print(valor)
plot(p1,p2,layout=(2,1))

