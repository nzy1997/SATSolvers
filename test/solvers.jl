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

    @test check_intersections(cl1, cl2) == true
    @test check_intersections(cl1, cl3) == true
    @test check_intersections(cl1, cl4) == false
    @test check_intersections(cl1, cl5) == true
    @test check_intersections(cl2, cl3) == false
end

@testset "directional_resolution" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])

    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])

    @test directional_resolution(problem)
end

@testset "random_problem" begin
    Random.seed!(1)
    num = 100
    for i in 1:num
        literal_num = rand(1:10)
        clause_num = rand(1:20)
        problem = random_problem(literal_num, clause_num)
        res1 = directional_resolution(problem)
        res2,ans = brute_force(problem)
        @test res1 == res2
        if res1 != res2
            @show problem
        end
    end
end
