using Test, SATSolvers,Random
using SATSolvers:BranchSATProblem

@testset "literal_branching" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])
    sat,ans = literal_branching(problem)
    @test sat == true
    @test check_answer(problem, ans) == true
    
    cl1 = SATClause(5, Int[], [1])
    cl2 = SATClause(5, [1], Int[])
    cl3 = SATClause(5, [4], [2])

    problem = SATProblem([cl1, cl2, cl3])
    sat,ans = literal_branching(problem)
    @test sat == false
    @test ans == []
end

@testset "clause_branching" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])
    sat,ans = clause_branching(problem)
    @test sat == true
    @test check_answer(problem, ans) == true

    cl1 = SATClause(5, Int[], [1])
    cl2 = SATClause(5, [1], Int[])
    cl3 = SATClause(5, [4], [2])

    problem = SATProblem([cl1, cl2, cl3])
    sat,ans = clause_branching(problem)
    @test sat == false
    @test ans == []
end

@testset "unit_resolution" begin
    cl1 = SATClause(5, [2], Int[])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    cl6 = SATClause(5, [1,5], Int[])
    problem = BranchSATProblem(Int[], fill(false, 5),SATProblem([cl1, cl2, cl3, cl4, cl5,cl6]))
    sat = unit_resolution(problem)

    @show sat.satproblem.clauses == cl6
end

@testset "literal_branching dpll" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])
    sat,ans = literal_branching(problem;dpll=true)
    @test sat == true
    @test check_answer(problem, ans) == true
    
    cl1 = SATClause(5, Int[], [1])
    cl2 = SATClause(5, [1], Int[])
    cl3 = SATClause(5, [4], [2])

    problem = SATProblem([cl1, cl2, cl3])
    sat,ans = literal_branching(problem;dpll=true)
    @test sat == false
    @test ans == []
end