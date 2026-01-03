using JuMP
using HiGHS
using SDDP
using Distributions

 # Onde x começa 
numero_de_iteracoes = 50 # numero de nós que serão considerados
idade = 5
estado_inicial = rand(DiscreteUniform(1,idade),idade)
especies=2

println(estado_inicial)
graph = SDDP.UnicyclicGraph(0.6; num_nodes=numero_de_iteracoes)


m = SDDP.PolicyGraph(graph; sense = :Max,upper_bound = 1000000.0, optimizer = HiGHS.Optimizer) do sp,t # subproblem, node
                    
                    @variable(sp, 0<=fs[i= 1:idade,k = 1:especies]<=1, SDDP.State, initial_value = 1/(idade*especies))
                    @variable(sp,c[i=1:idade,k=1:especies]>=0)
                    
                    @constraint(sp, sum(fs[i,k].out for i in idade, k in especies)==1)

                    
                    @constraint(sp,[k=1:especies],
                                    fs[1,k].out == sum(c[i,k] for i in 1:idade)
                                )
                   

                    #idade 2 a 4
                    @constraint(sp,[i=2:idade-1,k=1:especies], fs[i,k].out == fs[i-1,k].in - c[i-1,k] )
                    @constraint(sp,[i=1:idade,k=1:especies], c[i] <= fs[i,k].in)

                    σ = 1.0
                    s_meio = (1+idade)/2
                    v = [exp(-((s - s_meio)^2)/(2*σ^2)) for s in 1:idade]

                    @stageobjective(sp,sum(v[i]*v[k]*c[i,k]  for i in 1:idade, k=1:especies))
                    
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
