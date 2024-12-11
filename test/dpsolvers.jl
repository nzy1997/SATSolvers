using Test, SATSolvers,Random

@testset "brute_force" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])
    sat,ans = brute_force(problem)
    @test sat == true
    @test check_answer(problem, ans) == true
    
    cl1 = SATClause(5, Int[], [1])
    cl2 = SATClause(5, [1], Int[])
    cl3 = SATClause(5, [4], [2])

    problem = SATProblem([cl1, cl2, cl3])
    sat,ans = brute_force(problem)
    @test sat == false
    @test ans == []
end

@testset "resolve_clause" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])

    cl = resolve_clause(cl1, cl2, 1)
    @test cl.true_literals == [2]
    @test cl.false_literals == [3]
end

@testset "check_intersections" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])

    @test check_intersections(cl1, cl2,1) == true
    @test check_intersections(cl1, cl3,1) == false
    @test check_intersections(cl1, cl3,2) == true
    @test check_intersections(cl1, cl4,3) == false
    @test check_intersections(cl1, cl5,2) == false
    @test check_intersections(cl2, cl3,4) == false
end

@testset "directional_resolution" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])
    res1,ans1 = directional_resolution(problem)
    @test res1 == true
    @test check_answer(problem, ans1) == true


    cl1 = SATClause(5, Int[], Int[])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])
    res1,ans1 =directional_resolution(problem)
    @test res1 == false

    cl1 = SATClause(3, [1,2,3], Int[])
    cl2 = SATClause(3, [1,2], [3])
    cl3 = SATClause(3, [1,3], [2])
    cl4 = SATClause(3, [1], [2,3])
    cl5 = SATClause(3, [2,3], [1])
    cl6 = SATClause(3, [2], [1,3])
    cl7 = SATClause(3, [3], [1,2])
    cl8 = SATClause(3, Int[], [1,2,3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5, cl6, cl7, cl8])
    res1,ans1 =directional_resolution(problem) 
    @test res1 == false
end

@testset "check_empty_clause" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])
    @test check_empty_clause(problem) == false

    cl1 = SATClause(5, Int[], Int[])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])
    @test check_empty_clause(problem) == true
end

