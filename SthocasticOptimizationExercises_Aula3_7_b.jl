using JuMP
using HiGHS
using SDDP
using Distributions

 # Onde x começa 
numero_de_iteracoes = 50 # numero de nós que serão considerados
idade = 5
estado_inicial = rand(DiscreteUniform(1,idade),idade)


println(estado_inicial)
graph = SDDP.UnicyclicGraph(0.6; num_nodes=numero_de_iteracoes)


m = SDDP.PolicyGraph(graph; sense = :Max,upper_bound = 1000000.0, optimizer = HiGHS.Optimizer) do sp,t # subproblem, node
                    
                    @variable(sp, 0<=fs[i= 1:idade]<=1, SDDP.State, initial_value = 1/idade)
                    @variable(sp,c[i=1:idade]>=0)
                    
                    @constraint(sp, sum(fs[i].out for i in idade)==1)

                    
                    @constraint(sp,
                                    fs[1].out == sum(c[i] for i in 1:idade)
                                )
                   

                    #idade 2 a 4
                    @constraint(sp,[i=2:idade-1], fs[i].out == fs[i-1].in - c[i-1] )
                    @constraint(sp,[i=1:idade], c[i] <= fs[i].in)

                    σ = 1.0
                    s_meio = (1+idade)/2
                    v = [exp(-((s - s_meio)^2)/(2*σ^2)) for s in 1:idade]

                    @stageobjective(sp,sum(v[i]*c[i]  for i in 1:idade))
                    
                    # SDDP.parameterize(sp,[[0.0,100.0]]) do w
                    #     set_normalized_rhs(balance,w[1])
                    #     # set_normalized_rhs(summation,w[2])
                    # end
                end

SDDP.train(m, iteration_limit=10)


n_simulations = 10

simulations = SDDP.simulate(m, n_simulations,[:fs,:c];
                            sampling_scheme=SDDP.InSampleMonteCarlo(;max_depth=50,terminate_on_dummy_leaf=false,),
                            )

                            

println("Valores das variáveis x_i:")
outgoing_volume = map(simulations[1]) do node
    return node[:c]
end
