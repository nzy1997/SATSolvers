using SATSolvers,Test,Random

@testset "SATProblem" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [1])
    @test_throws AssertionError SATClause(3, [4], [2])
    @test always_true_clause(cl1) == false
    @test always_true_clause(cl2) == true
end

@testset "SATProblem" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])
    @test literal_count(problem) == 5
    @test clause_count(problem) == 5
end

@testset "check_clause" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])

    @test check_clause(cl1, [false, true, false, false, false]) == true
    @test check_clause(cl1, [false, false, false, false, false]) == true

    @test check_clause(cl2, [true, false, false, false, false]) == true
    @test check_clause(cl2, [false, false, false, false, false]) == true

    @test check_clause(cl5, [false, false, false, true, false]) == true
    @test check_clause(cl5, [false, false, true, true, false]) == false
end

@testset "check_answer" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3]) 
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])

    @test check_answer(problem, [true, false, true, false, false]) == false
    @test check_answer(problem, [true, true, true, false, false]) == false
    @test check_answer(problem, [false, false, false, false, false]) == true
    @test check_answer(problem, [false, true, false, false, false]) == false
end

@testset "random_problem" begin
    Random.seed!(1)
    problem = random_problem(5, 5)
    @test literal_count(problem) == 5
    @test clause_count(problem) == 5
end


@testset "random_problem_test" begin
    Random.seed!(345)
    num = 100
    for i in 1:num
        literal_num = rand(1:10)
        clause_num = rand(1:50)
        problem = random_problem(literal_num, clause_num)
        res1,ans1 = directional_resolution(problem)
        res2,ans2 = brute_force(problem)
        res3,ans3 = literal_branching(problem)
        res4,ans4 = clause_branching(problem)
        @test res1 == res2
        @test res1 == res3
        @test res1 == res4
        if res1 
            @test check_answer(problem, ans1) == true
            @test check_answer(problem, ans2) == true
            @test check_answer(problem, ans3) == true
            @test check_answer(problem, ans4) == true
        end
        if res1 != res2
            @show problem
        end
    end
end
