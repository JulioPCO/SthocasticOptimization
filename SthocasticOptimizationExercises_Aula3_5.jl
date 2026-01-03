using JuMP
using HiGHS
using SDDP

estado_inicial = 100 # Onde x começa 
numero_de_iteracoes = 50 # numero de nós que serão considerados

graph = SDDP.UnicyclicGraph(0.9; num_nodes=numero_de_iteracoes)


m = SDDP.PolicyGraph(graph; sense = :Min,lower_bound = 0.0, optimizer = HiGHS.Optimizer) do sp,t # subproblem, node
                    @variable(sp, -10<=x<=estado_inicial, SDDP.State, initial_value = estado_inicial)
                    @variable(sp,g)
                    @constraint(sp,balance, x.out == x.in - g)
                    #Ultimo nó tem que ser =0
                    if t == numero_de_iteracoes
                        @constraint(sp,condicao_terminal, x.out == 0)
                    end 
                    #
                    @stageobjective(sp,g^2)
                    
                    # SDDP.parameterize(sp,[[0.0,100.0]]) do w
                    #     set_normalized_rhs(balance,w[1])
                    #     # set_normalized_rhs(summation,w[2])
                    # end
                end

SDDP.train(m, iteration_limit=10)


n_simulations = 10

simulations = SDDP.simulate(m, n_simulations,[:x,:g];
                            sampling_scheme=SDDP.InSampleMonteCarlo(;max_depth=50,terminate_on_dummy_leaf=false,),
                            )

println("Valores das variáveis x_i:")
outgoing_volume = map(simulations[1]) do node
    return node[:g]
end