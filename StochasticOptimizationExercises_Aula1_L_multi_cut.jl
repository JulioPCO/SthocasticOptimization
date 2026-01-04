
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

    v= []
    z= []
    pis = []
    p=[]
    for (qi,di,pi) in dist
        JuMP.fix(q,qi)
        JuMP.fix(d,di)
        optimize!(m2)
        # Valor esperado da otimização do segundo estágio
        append!(z, objective_value(m2))
        append!(v,pi*objective_value(m2))
        append!(p,pi)
        # MULTIPLICADOR DE LAGRANGE DA OTIMIZAÇÃO DE SEGUNDO ESTÁGIO QUE É UTILIZADO NA OTIMIZAÇÃO DO PRIMEIRO ESTÁGIO
        append!(pis, reduced_cost(x_chapeu))
    end

    return v,pis,z,p
end


function L_shaped(m1,x0,dist)
    x=m1[:x]

    objfun = objective_function(m1)
    @variable(m1, thetas[1:200])
    # @variable(m1,theta)
    # @objective(m1,Max,objfun+theta)
    @objective(m1,Max,objfun+ sum(p[i] * thetas[i] for i in 1:200))

    k=0
    xi=x0
    vs = [-Inf]
    for k in 1 :2
        v,pis,z,p = funcao_valor(xi,dist)

        gap = abs(vs[end]-sum(v))
        
        append!(vs,sum(v))
        if gap<1e-4
            break
        end
        
        for (i,a) in enumerate(z)
            @constraint(m1,thetas[i]<=a+pis[i]*(x - xi))
        end

        
        optimize!(m1)

        xi = value.(x)
        println(xi)
    end
    
    return value(x)
end

function problema_L_shaped(dist)
    m1 = Model(HiGHS.Optimizer)
    set_silent(m1)

    @variable(m1, 0<= x<=350)

    @objective(m1,Max, -100x)
    x0=100

    xs = L_shaped(m1,x0,dist)

    return xs
end

xa=[]
for j in 1:1
    x = problema_L_shaped(dist)
    append!(xa,x)
end

println(mean(xa))


