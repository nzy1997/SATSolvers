using SATSolvers,Test

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

