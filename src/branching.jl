struct BranchSATProblem
    fixed_vars::Vector{Int}
    values::Vector{Bool}
    satproblem::SATProblem
end

literal_count(problem::BranchSATProblem) = literal_count(problem.satproblem)


function remove_literal(cl::SATClause, literal::Int)
    return SATClause(cl.literal_num, setdiff(cl.true_literals, [literal]), setdiff(cl.false_literals, [literal]))
end

function remove_linenums(bsp::BranchSATProblem, i::Int,b::Bool)
    clauses = SATClause[]
    for cl in bsp.satproblem.clauses
        if (i in cl.true_literals && b) || (i in cl.false_literals && !b)
            continue
        elseif i in cl.true_literals || i in cl.false_literals
            push!(clauses, remove_literal(cl, i))
        else
            push!(clauses, cl)
        end
    end
    ans = copy(bsp.values)
    ans[i] = b
    return BranchSATProblem(bsp.fixed_vars ∪ [i], ans, SATProblem(clauses))
end

function literal_branching(sp::SATProblem)
    return literal_branching(BranchSATProblem(Int[], fill(false, literal_count(sp)), sp))
end

function literal_branching(bsp::BranchSATProblem)
    if check_empty_clause(bsp.satproblem)
        return false, []
    end
    if length(bsp.satproblem.clauses) == 0
        return true, bsp.values
    end

    i = setdiff(1:literal_count(bsp),bsp.fixed_vars)[1]

    res,ans = literal_branching(remove_linenums(bsp, i, true))
    if res
        return true, ans
    end

    res,ans = literal_branching(remove_linenums(bsp, i, false))
    if res
        return true, ans
    end
    return false, []
end

# Exact Exponential Algorithm P21
# function ksat1()

# end