struct LiteralStatus
	value::Bool
	decision_level::Int
	decision_parents::Vector{Int}
end

function cdcl(problem::SATProblem)
	if check_empty_clause(problem)
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

	while true
		if all(==(-1), undefined_variable_num)
			return true, getfield.(values,:value)
		end
		level += 1

		literal = findfirst(x -> x.decision_level == -1, values)

		#decide literal to be true
		values, undefined_variable_num = decide_literal!(problem, values, level, undefined_variable_num, true, literal, Int[])
		push!(uvn_record, undefined_variable_num)
		push!(values_record, values)
    	values, undefined_variable_num = unit_resolution!(problem, values, level, undefined_variable_num)

		while any(==(0), undefined_variable_num)
			if level == 0
				return false, []
			end

			fuip,mlevel,recorded_list,val = first_unique_implication_point(problem, values, level, undefined_variable_num)
            level = mlevel
            values = values_record[mlevel+1]
            undefined_variable_num = uvn_record[mlevel+1]

			values_record = values_record[1:mlevel]
			uvn_record = uvn_record[1:mlevel]
            values, undefined_variable_num = decide_literal_with_unit_resolution!(problem, values, level, undefined_variable_num, val, fuip, recorded_list)

			push!(values_record, values)
			push!(uvn_record, undefined_variable_num)
		end
		uvn_record[end] = undefined_variable_num
		values_record[end] = values
	end
end


function first_unique_implication_point(problem::SATProblem, values::Vector{LiteralStatus}, level::Int, undefined_variable_num::Vector{Int})
	cl = problem.clauses[findfirst(==(0), undefined_variable_num)]

	var_queue = [i for i in cl.true_literals ∪ cl.false_literals if values[i].decision_level == level]
	recorded_list = [i for i in cl.true_literals ∪ cl.false_literals if values[i].decision_level < level]
	while true
		i = var_queue[1]
        literal_status = values[popfirst!(var_queue)]
		if isempty(literal_status.decision_parents)
			var_queue = var_queue ∪ i
			continue
		end
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
		cl = problem.clauses[i]
        if undefined_variable_num[i] == -1
            if (lit_num in cl.true_literals && (!b)) || (lit_num in cl.false_literals && (b))
				for i in cl.true_literals ∪ cl.false_literals
					ib = i in cl.true_literals
					if values[i].decision_level >=0 
						if values[i].value == ib
							break
						end
					end
				end
			end
			continue
        end
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

function print_state(values,undefined_variable_num,level)
	@show level
	@show getfield.(values,:value)
	@show undefined_variable_num
	@show getfield.(values,:decision_level)
	@show getfield.(values,:decision_parents)
end