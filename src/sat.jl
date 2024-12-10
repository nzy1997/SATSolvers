"""
    SATProblem

A SAT problem is a set of clauses, each of which is a set of literals.

# Fields
- `clauses::Matrix{Int}`: A matrix where each row is a clause, 1 stands for a positive literal and 2 for a negative literal, 0 for no literal.
"""
struct SATProblem
    clauses::Matrix{Int}
end

variable_count(problem::SATProblem) = size(problem.clauses, 2)
clause_count(problem::SATProblem) = size(problem.clauses, 1)
 

function check_clause(clause::AbstractArray{Int}, answer::AbstractVector{Bool})
    return mapreduce(x->x, |, [clause[i] == 0 ? false : (clause[i] == 1 ? answer[i] : !answer[i]) for i in 1:length(clause)]) 
end
function check_answer(problem::SATProblem, answer::AbstractVector{Bool})
    return mapreduce(x->check_clause(x,answer), &, eachrow(problem.clauses))
end

