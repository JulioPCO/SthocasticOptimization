
using Pkg
Pkg.activate(".")

using JuMP
using HiGHS
using Distributions
using Plots



n_cenarios = 200

tempo = []
valor = []
id = []
plt = plot(title="Ex 1 - resultado",legend=false,marker=2)
plt2 = plot(title="Ex 1 - tempo",legend=false,marker=2)


p = ones(n_cenarios,n_cenarios)*1/n_cenarios

q = rand(Uniform(80,150),n_cenarios) 
d = rand(Uniform(300,500),n_cenarios) 

dist = collect(zip(q,d,p))

function funcao_valor(x,dist)
    m2 = Model(HiGHS.Optimizer)
    set_silent(m2)

    @variable(m2,q)
    @variable(m2,d)
    @variable(m2,y >=0)
    @variable(m2, x_chapeu)

    @constraint(m2, y+x_chapeu >=d)

    @objective(m2,Max,-q*y)

    JuMP.fix(x_chapeu,x)

    v=0.0
    pis = 0.0
    for (qi,di,pi) in dist
        JuMP.fix(q,qi)
        JuMP.fix(d,di)
        optimize!(m2)
        # Valor esperado da otimização do segundo estágio
        v+= pi*objective_value(m2)
        # MULTIPLICADOR DE LAGRANGE DA OTIMIZAÇÃO DE SEGUNDO ESTÁGIO QUE É UTILIZADO NA OTIMIZAÇÃO DO PRIMEIRO ESTÁGIO
        pis += pi*reduced_cost(x_chapeu)
    end

    return v,pis
end


function L_shaped(m1,x0,dist)
    x=m1[:x]

    @variable(m1,theta)

    objfun = objective_function(m1)
    @objective(m1,Max,objfun+theta)

    k=0
    xi=x0
    vs = [-Inf]
    for k in 1 :100
        v,pis = funcao_valor(xi,dist)
        gap = abs(vs[end]-v)

        println(v)
        append!(vs,v)
        if gap<1e-4
            break
        end

        @constraint(m1,theta<=v+pis*(x - xi))
        optimize!(m1)

        xi = value.(x)
    end

    println(m1)
    return value(x),value(theta),k
end

function problema_L_shaped(dist)
    m1 = Model(HiGHS.Optimizer)
    set_silent(m1)

    @variable(m1, 0<= x<=350)

    @objective(m1,Max, -100x)
    x0=100

    xs,theta,k = L_shaped(m1,x0,dist)

    return xs,theta
end

xa=[]
for j in 1:20
    x,theta = problema_L_shaped(dist)
    append!(xa,x)
end

println(mean(xa))


