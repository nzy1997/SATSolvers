using SATSolvers
# Example from Handbook of Satisfiability Example 4.2.5
@testset "cdcl examples" begin
    cl1 = SATClause(8, [8], [3,2])
    cl2 = SATClause(8, [4], [3])
    cl3 = SATClause(8, [5], [8,4])
    cl4 = SATClause(8, [6], [5,1])
    cl5 = SATClause(8, [7], [5])
    cl6 = SATClause(8, Int[], [6,7])

    problem = SATProblem([cl1, cl2, cl3, cl4, cl5, cl6])
    sat,answer = cdcl(problem;viz = true)
end