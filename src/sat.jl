struct SATClause
    literal_num::Int
    true_literals::Vector{Int}
    false_literals::Vector{Int}

    function SATClause(literal_num::Int, true_literals::Vector{Int}, false_literals::Vector{Int})
        (true_literals == []) || @assert maximum(true_literals) ≤ literal_num
        (false_literals == []) || @assert maximum(false_literals) ≤ literal_num
        return new(literal_num, sort(true_literals), sort(false_literals))
    end
end

function always_true_clause(cl::SATClause)
    return any(x->x ∈ cl.false_literals, cl.true_literals) 
end

struct SATProblem
    clauses::Vector{SATClause}
end

literal_count(problem::SATProblem) = problem.clauses[1].literal_num
clause_count(problem::SATProblem) = length(problem.clauses)
 

function check_clause(clause::SATClause, answer::AbstractVector{Bool})
    for i in clause.true_literals
        if answer[i]
            return true
        end
    end
    for i in clause.false_literals
        if !answer[i]
            return true
        end
    end
    return false
end

function check_answer(problem::SATProblem, answer::AbstractVector{Bool})
    return mapreduce(x->check_clause(x,answer), &, (problem.clauses))
end