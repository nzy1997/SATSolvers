struct LiteralStatus
	value::Bool
	decision_level::Int
	decision_parents::Vector{Int}
end

function cdcl(problem::SATProblem)
	if check_empty_clause(bsp.satproblem)
		return false, []
	end

	values = [LiteralStatus(false, -1, Int[]) for _ in 1:literal_count(problem)]
	undefined_variable_num = [length(cl.true_literals) + length(cl.false_literals) for cl in problem.clauses]
	unit_resolution!(problem, values, 0, undefined_variable_num)
	if any(==(0), undefined_variable_num)
		return false, []
	end

	level = 0

    uvn_record = [undefined_variable_num]
    values_record = [values]
    skip_decision = false
	while true
        if skip_decision
            skip_decision = false
        else
            level += 1
            literal = findfirst(x -> x.decision_level == -1, values)

            #decide literal to be true
            values, undefined_variable_num = decide_literal_with_unit_resolution!(problem, values, level, undefined_variable_num, true, literal, Int[])
        end
		if any(==(0), undefined_variable_num)
			fuip,mlevel,recorded_list,val = first_unique_implication_point(problrm, values, level, undefined_variable_num)
            level = mlevel
            values = values_record[mlevel+1]
            undefined_variable_num = uvn_record[mlevel+1]
            decide_literal_with_unit_resolution!(problem, values, level, undefined_variable_num, val, fuip, recorded_list)
            skip_decision = true
		end
        

	end




end


function first_unique_implication_point(problem::SATProblem, values::Vector{LiteralStatus}, level::Int, undefined_variable_num::Vector{Int})
	cl = problem.clauses[findfirst(==(0), undefined_variable_num)]

	var_queue = [i for i in cl.true_literals ∪ cl.false_literals if values[i].decision_level == level]

	recorded_list = [i for i in cl.true_literals ∪ cl.false_literals if values[i].decision_level < level]
	while true
        literal_status = values[popfirst!(var_queue)]
		for i in literal_status.decision_parents
			if values[i].decision_level < level
				recorded_list = recorded_list ∪ i
			else
                var_queue = var_queue ∪ i
			end
		end
        if length(var_queue) == 1
            break
        end
	end
    mlevel = maximum([values[i].decision_level for i in recorded_list])
    return var_queue[1], mlevel, recorded_list, !values[var_queue[1]].value
end

# TODO: Not dry!!!!
function unit_resolution!(problem::SATProblem, values::Vector{LiteralStatus}, level::Int, undefined_variable_num::Vector{Int})
	while true
		unit_clause_num = findfirst(==(1), undefined_variable_num)
		if isnothing(unit_clause_num)
			break
		end
		unit_clause = problem.clauses[unit_clause_num]
		unit_literal = 0
		parents = Int[]

		for i in unit_clause.true_literals ∪ unit_clause.false_literals
			if values[i].decision_level >= 0
				parents = parents ∪ i
			else
				unit_literal = i
			end
		end
		unit_value = unit_literal ∈ unit_clause.true_literals

        undefined_variable_num[unit_clause_num] = -1

		values, undefined_variable_num = decide_literal!(problem, values, level, undefined_variable_num, unit_value, unit_literal, parents)
	end
	return values, undefined_variable_num
end

function decide_literal!(problem::SATProblem, values::Vector{LiteralStatus}, level::Int, undefined_variable_num::Vector{Int},b::Bool,lit_num::Int,parents::Vector{Int})
    values[lit_num] = LiteralStatus(b, level, parents)
    for i in 1:length(problem.clauses)
        if undefined_variable_num[i] == -1
            continue
        end
        cl = problem.clauses[i]
        if (lit_num in cl.true_literals) && (!b) || (lit_num in cl.false_literals) && (b)
            undefined_variable_num[i] -= 1
        elseif (lit_num in cl.true_literals) && (b) || (lit_num in cl.false_literals) && (!b)
            undefined_variable_num[i] = -1
        end
    end
    return values, undefined_variable_num
end

function decide_literal_with_unit_resolution!(problem::SATProblem, values::Vector{LiteralStatus}, level::Int, undefined_variable_num::Vector{Int},b::Bool,lit_num::Int,parents::Vector{Int})
    values, undefined_variable_num = decide_literal!(problem, values, level, undefined_variable_num, b, lit_num, parents)
    return unit_resolution!(problem, values, level, undefined_variable_num)
end