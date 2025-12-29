using JuMP, HiGHS, LinearAlgebra, Distributions


c = -0.75
L = -100.0   
x_k = 0.0    
V = Vector{Vector{Float64}}() 
cenarios_h = Vector{Vector{Float64}}() 
dist = Uniform(-1, 0)


cortes_alpha = Float64[]
cortes_beta = Float64[]

# Matrizes do problema
T_col = [10.0; 5.0]
W_T = [-1.0 -1.0; 1.0 1.0; -1.0 1.0; 1.0 -1.0]
q = [-1.0, 3.0, 1.0, 1.0]


for k in 1:3
    global x_k

    # Passo 1: Sortear w e gerar h_k
    w1 = rand(dist)
    h_k = [w1; 1 + w1]
    push!(cenarios_h, h_k)
    
    # Passo 2(a): Resolver subproblema dual para o x atual
    sub = Model(HiGHS.Optimizer); set_silent(sub)
    @variable(sub, p[1:2])
    @objective(sub, Max, dot(p, h_k - T_col * x_k))
    @constraint(sub, W_T * p .<= q)
    optimize!(sub)
    
    p_k = value.(p)
    push!(V, p_k) 
    
    # Passo 2(b) e (c): Cálculo do novo corte e atualização dos antigos
    # Primeiro, atualizamos os coeficientes dos cortes existentes (Regra c)
    for i in 1:length(cortes_alpha)
        cortes_alpha[i] = ((k - 1) / k) * cortes_alpha[i] + (1/k) * L
        cortes_beta[i]  = ((k - 1) / k) * cortes_beta[i]
        
    end
    
    # Agora calculamos o NOVO corte (k-ésimo plano) (Regra b)
    # Soma de p_t * (h_t - T*x) para t=1 até k
    soma_alpha = 0.0
    soma_beta = 0.0
    
    
    for t in 1:k
        h_t = cenarios_h[t]
        # Escolhe o melhor p do estoque V para o cenário t
        p_escolhido = argmax(p -> dot(p, h_t - T_col * x_k), V)

        soma_alpha += dot(p_escolhido, h_t)
        soma_beta  += dot(p_escolhido, -T_col)
    end
    
    push!(cortes_alpha, soma_alpha / k)
    push!(cortes_beta,  soma_beta / k)

    # Passo 3: Resolver o Problema Mestre
    mestre = Model(HiGHS.Optimizer); set_silent(mestre)
    @variable(mestre, 0 <= x <= 5)
    @variable(mestre, eta >= L)
    
    @objective(mestre, Min, c * x + eta)
    
    # Adiciona todos os cortes acumulados até agora
    for i in 1:length(cortes_alpha)
        @constraint(mestre, eta >= cortes_alpha[i] + cortes_beta[i] * x)
    end
    
    optimize!(mestre)
    x_k = value(x)

    println(cortes_beta)
    println("Cenário h: ", round.(h_k, digits=3))
    println("Novo x encontrado: ", round(x_k, digits=4))
    println("Aproximação eta: ", round(value(eta), digits=4))
end