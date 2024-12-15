using Karnak, Graphs, NetworkLayout, Colors, SimpleWeightedGraphs
using Test, SATSolvers,Random
using SATSolvers:LiteralStatus,update_uvn

@testset "vizall" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])

    lss = [LiteralStatus(false, -1, Int[],1) for _ in 1:literal_count(problem)]
    lss[1]= LiteralStatus(true, 1, Int[],0)
    lss[2]= LiteralStatus(false, 1, [1],0)
    lss[3]= LiteralStatus(false, -1, Int[],0)
    lss[4]= LiteralStatus(false, -1, Int[],0)
    lss[5]= LiteralStatus(false, 1, [1,2], 2)

    undefined_variable_num = [update_uvn(cl,lss) for cl in problem.clauses]
    d1 = vizlss(lss)

    d2 = vizall(lss,problem,undefined_variable_num)
    display(d2)
end
