struct LiteralStatus
    value::Bool
    decision_level::Int
    decision_parents::Vector{Int}
end

function cdcl(problem::SATProblem)
    if check_empty_clause(bsp.satproblem)
		return false, [], true
	end

    values = [LiteralStatus(false, -1, Int[]) for _ in 1:literal_count(problem)]
    undifined_varible_num = [length(cl.true_literals) + length(cl.false_literals) for cl in problem.clauses]
    unit_resolution!(problem,values,level,undifined_variable_num)


end

# TODO: Not dry!!!!
function unit_resolution!(problem::SATProblem,values::Vector{LiteralStatus},level::Int,undifined_variable_num::Vector{Int})
    while true
        unit_clause = findfirst(==(1),undifined_variable_num)
        if isnothing(unit_clause)
            break
        end
        unit_clause = problem.clauses[unit_clause]
        unit_literal = 0
        parents = []
        
        for i in unit_clause.true_literals ∪ unit_clause.false_literals
            if values[i].decision_level >= 0 
                parents = parents ∪ {i}
            else
                unit_literal = i
            end
        end
        unit_value = unit_literal ∈ unit_clause.true_literals

        values[unit_literal] = LiteralStatus(unit_value,level,parents)
        
        for i in 1:length(problem.clauses)
            if undifined_variable_num[i] == -1
                continue
            end
            cl = problem.clauses[i]
            if (unit_literal in cl.true_literals) && (!unit_value) || (unit_literal in cl.false_literals) && (unit_value)
                undifined_variable_num[i] -= 1
            end
            if unit_literal in cl.false_literals
                cl.false_literals = setdiff(cl.false_literals,[unit_literal])
            end
        end

    end
    return values, undifined_varible_num
end