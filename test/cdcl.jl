using Test, SATSolvers,Random
using SATSolvers:LiteralStatus,update_uvn


@testset "unit_resolution!" begin
    cl1 = SATClause(5, [2], Int[])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    cl6 = SATClause(5, [1], [5])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5,cl6])

    values,undefined_varible_num = unit_resolution!(problem, [LiteralStatus(false, -1, Int[],0) for _ in 1:literal_count(problem)], 0, [length(cl.true_literals) + length(cl.false_literals) for cl in problem.clauses])

    @test values[2].decision_level == 0
    @test values[2].decision_parents == Int[]
    @test values[2].value == true

    @test values[3].decision_level == 0
    @test values[3].decision_parents == [4]
    @test values[3].value == false

    @test values[1].decision_level == -1
    @test values[1].decision_parents == Int[]

    @test undefined_varible_num == [-1, -1, -1, -1, -1, 2]

end

# Example from Handbook of Satisfiability Example 4.2.5
@testset "first_unique_implication_point" begin
    cl1 = SATClause(8, [3], [1,2])
    cl2 = SATClause(8, [4], [1])
    cl3 = SATClause(8, [5], [3,4])
    cl4 = SATClause(8, [6], [5,8])
    cl5 = SATClause(8, [7], [5])
    cl6 = SATClause(8, Int[], [6,7])

    problem = SATProblem([cl1, cl2, cl3, cl4, cl5, cl6])

    values = [LiteralStatus(false, -1, Int[],0) for _ in 1:literal_count(problem)]
    undefined_variable_num = [length(cl.true_literals) + length(cl.false_literals) for cl in problem.clauses]

    decide_literal_with_unit_resolution!(problem, values, 1, undefined_variable_num, true, 8, Int[],0)

    decide_literal_with_unit_resolution!(problem, values, 2, undefined_variable_num, true, 2, Int[],1)
    @test undefined_variable_num == [2, 2, 3, 2, 2, 2]

    decide_literal!(problem, values, 3, undefined_variable_num, true, 1, Int[],1)
    @test undefined_variable_num == [1, 1, 3, 2, 2, 2]
    values,undefined_varible_num = unit_resolution!(problem, values, 3, undefined_variable_num)
    @test undefined_variable_num == [-1, -1, -1, -1, -1, 0]

    @test values[1].decision_level == 3
    @test values[1].decision_parents == Int[]

    @test values[2].decision_level == 2

    @test values[3].decision_parents == [1,2]
    @test values[3].decision_level == 3

    @test values[4].decision_level == 3
    @test values[4].decision_parents == [1]

    @test values[5].decision_level == 3
    @test values[5].decision_parents == [3,4]

    @test values[6].decision_level == 3
    @test values[6].decision_parents == [5,8]

    fuip,mlevel,recorded_list,val = first_unique_implication_point(problem, values, 3, undefined_variable_num)
    @test fuip == 5
    @test mlevel == 1
    @test recorded_list == [8]
    @test !val
end

@testset "cdcl" begin
    cl1 = SATClause(5, [2], [1])
    cl2 = SATClause(5, [1], [3])
    cl3 = SATClause(5, [4], [2])
    cl4 = SATClause(5, Int[], [3,4])
    cl5 = SATClause(5, [1,5], [3])
    problem = SATProblem([cl1, cl2, cl3, cl4, cl5])
    sat,answer = cdcl(problem)

    @test sat == true
    @test check_answer(problem, answer) == true


    cl1 = SATClause(5, Int[], [1])
    cl2 = SATClause(5, [1], Int[])
    cl3 = SATClause(5, [4], [2])

    problem = SATProblem([cl1, cl2, cl3])
    sat,answer = cdcl(problem)
    @test sat == false
    @test answer == []
end

@testset "cdcl" begin
    problem = SATProblem(SATClause[SATClause(4, Int64[], [1, 3, 4]), SATClause(4, Int64[], [1, 2, 3, 4]), SATClause(4, [4], [1, 2, 3]), SATClause(4, [2], [1, 4]), SATClause(4, [3], [1, 2]), SATClause(4, [1, 3, 4], Int64[]), SATClause(4, [3, 4], [2]), SATClause(4, [1], [3]), SATClause(4, [2, 3], [1, 4]), SATClause(4, [2], [3]), SATClause(4, [1, 4], [2, 3]), SATClause(4, [1, 2, 3], [4]), SATClause(4, Int64[], [2, 3]), SATClause(4, [3, 4], Int64[]), SATClause(4, [1, 3, 4], [2]), SATClause(4, [1, 2, 4], [3])])
    @show sat,answer = cdcl(problem;viz = false)
end

@testset "update_uvn" begin
    cl = SATClause(5, [2,3,4], [1,5])

    values = [LiteralStatus(false, -1, Int[],1) for _ in 1:literal_count(cl)]
    @test update_uvn(cl, values) == 5

    values[1]= LiteralStatus(true, 1, Int[],2)
    @test update_uvn(cl, values) == 4

    values[2]= LiteralStatus(true, 1, Int[],0)
    @test update_uvn(cl, values) == -1

    values[3]= LiteralStatus(true, 1, Int[],1)
    @test update_uvn(cl, values) == -1

    values[2]= LiteralStatus(false, 1, Int[],0)
    @test update_uvn(cl, values) == -1 

    values[3]= LiteralStatus(false, 1, Int[],2)
    @test update_uvn(cl, values) == 2

end