struct LiteralStatus
    value::Bool
    decision_level::Int
    decision_parents::Vector{Int}
end

struct CDCLSATProblem
    values::Vector{LiteralStatus}
    satproblem::SATProblem
end

function cdcl(problem::SATProblem)
    values = [LiteralStatus(false, 0, Int[]) for _ in 1:literal_count(problem)]
    return cdcl(CDCLSATProblem(values, problem))
end

function cdcl(csp::CDCLSATProblem)
    res, ans = check_termination(csp)
    if res
        return ans
    end

    i = setdiff(1:literal_count(csp), [x for x in 1:literal_count(csp) if csp.values[x].decision_level == 0])[1]

    res, ans = cdcl(set_literal(csp, i, true))
    if res
        return ans
    end

    res, ans = cdcl(set_literal(csp, i, false))
    if res
        return ans
    end

    return false
end