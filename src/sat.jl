struct SATClause
    literal_num::Int
    true_literals::Vector{Int}
    false_literals::Vector{Int}

    function SATClause(literal_num::Int, true_literals::Vector{Int}, false_literals::Vector{Int})
        isempty(true_literals) || @assert maximum(true_literals) ≤ literal_num
        isempty(false_literals) || @assert maximum(false_literals) ≤ literal_num
        return new(literal_num, sort(true_literals), sort(false_literals))
    end
end

Base.:(==)(cl1::SATClause, cl2::SATClause) = cl1.literal_num == cl2.literal_num && cl1.true_literals == cl2.true_literals && cl1.false_literals == cl2.false_literals

Base.hash(cl::SATClause, h::UInt) = hash(cl.literal_num, hash(cl.true_literals, hash(cl.false_literals, h)))

function always_true_clause(cl::SATClause)
    return any(x->x ∈ cl.false_literals, cl.true_literals) 
end

struct SATProblem
    clauses::Vector{SATClause}
    function SATProblem(clauses::Vector{SATClause})
        return new(unique(clauses))
    end
end

literal_count(problem::SATProblem) = problem.clauses[1].literal_num
clause_count(problem::SATProblem) = length(problem.clauses)
 
literal_count(cl::SATClause) = cl.literal_num

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

function random_problem(literal_num::Int, clause_num::Int)
    clauses = SATClause[]
    for _ in 1:clause_num
        true_literals = sample(1:literal_num, rand(0:literal_num-1), replace=false)
        false_literals = sample(setdiff(1:literal_num,true_literals), rand(0:literal_num-length(true_literals)), replace=false)
        push!(clauses, SATClause(literal_num, true_literals, false_literals))
    end
    return SATProblem(clauses)
end