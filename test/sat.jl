using SATSolvers,Test


@testset "SATProblem" begin
    problem = SATProblem([2 2 1 0 0; 2 2 0 1 1])
    @test variable_count(problem) == 5
    @test clause_count(problem) == 2
end

@testset "check_clause" begin
    @test check_clause([1 2 0], [true, false, true]) == true
    @test check_clause([1 2 0], [true, true, true]) == true
    @test check_clause([1 2 0], [false, false, false]) == true
    @test check_clause([1 2 0], [false, true, false]) == false
end

@testset "check_answer" begin
    problem = SATProblem([2 2 1 0 0; 2 2 0 1 1])
    @test check_answer(problem, [true, false, true, false, false]) == true
    @test check_answer(problem, [true, true, true, false, false]) == false
    @test check_answer(problem, [false, false, false, false, false]) == true
    @test check_answer(problem, [false, true, false, false, false]) == true
end

