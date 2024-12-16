struct LiteralStatus
	value::Bool
	decision_level::Int
	decision_parents::Vector{Int}
	decision_clause::Int
end

function cdcl(problem::SATProblem;viz = false)
	if check_empty_clause(problem)
		return false, []
	end


	lss = [LiteralStatus(false, -1, Int[],0) for _ in 1:literal_count(problem)]
	undefined_variable_num = [length(cl.true_literals) + length(cl.false_literals) for cl in problem.clauses]
	lss, undefined_variable_num = unit_resolution!(problem, lss, 0, undefined_variable_num)
	if any(==(0), undefined_variable_num)
		return false, []
	end

	level = 0

	viz && (fignum = vizall(lss,problem,undefined_variable_num,0))

    uvn_record = [copy(undefined_variable_num)]
    lss_record = [copy(lss)]
	level_literal = Int[]
	while true
		if all(==(-1), undefined_variable_num)
			return true, getfield.(lss,:value)
		end
		level += 1
		literal = findfirst(x -> x.decision_level == -1, lss)
		push!(level_literal, literal)

		#decide literal
		
		boolvalue = lss[literal].value
		lss, undefined_variable_num = decide_literal!(problem, lss, level, undefined_variable_num, !boolvalue, literal, Int[],0)
		push!(uvn_record, copy(undefined_variable_num))
		push!(lss_record, copy(lss))

		viz && (fignum = vizall(lss,problem,undefined_variable_num,fignum))

    	lss, undefined_variable_num = unit_resolution!(problem, lss, level, undefined_variable_num)

		viz && (fignum = vizall(lss,problem,undefined_variable_num,fignum))

		while any(==(0), undefined_variable_num)
			if level == 0
				return false, []
			end

			fuip,mlevel,recorded_list,val,dc = first_unique_implication_point(problem, lss, level, undefined_variable_num)
			if recorded_list == Int[] 
				level = 0
				lss = lss_record[1]
				undefined_variable_num = uvn_record[1]
				lss, undefined_variable_num = decide_literal!(problem, lss, level, undefined_variable_num, val, fuip, Int[],0)

				viz && (fignum = vizall(lss,problem,undefined_variable_num,fignum))
		
				lss, undefined_variable_num = unit_resolution!(problem, lss, level, undefined_variable_num)
		
				viz && (fignum = vizall(lss,problem,undefined_variable_num,fignum))

				uvn_record = [copy(undefined_variable_num)]
				lss_record = [copy(lss)]
				continue
			end
            level = mlevel
            lss = lss_record[mlevel+1]
            undefined_variable_num = uvn_record[mlevel+1]

			lss_record = lss_record[1:mlevel]
			uvn_record = uvn_record[1:mlevel]
	

            lss, undefined_variable_num = decide_literal_with_unit_resolution!(problem, lss, level, undefined_variable_num, val, fuip, recorded_list,dc)
			push!(lss_record, copy(lss))
			push!(uvn_record, copy(undefined_variable_num))

			viz && (fignum = vizall(lss,problem,undefined_variable_num,fignum))

		end
		uvn_record[end] = copy(undefined_variable_num)
		lss_record[end] = copy(lss)
	end
end


function first_unique_implication_point(problem::SATProblem, lss::Vector{LiteralStatus}, level::Int, undefined_variable_num::Vector{Int})
	cl_num = findfirst(==(0), undefined_variable_num)
	cl = problem.clauses[cl_num]
	var_queue = [i for i in cl.true_literals ∪ cl.false_literals if lss[i].decision_level == level]
	recorded_list = [i for i in cl.true_literals ∪ cl.false_literals if lss[i].decision_level < level]
	while true
		# @show "2"
		i = var_queue[1]
        literal_status = lss[popfirst!(var_queue)]
		if isempty(literal_status.decision_parents)
			var_queue = var_queue ∪ i
			if length(var_queue) == 1
				break
			end
			continue
		end
		for i in literal_status.decision_parents
			if lss[i].decision_level < level
				recorded_list = recorded_list ∪ i
			else
                var_queue = var_queue ∪ i
			end
		end

        if length(var_queue) == 1
            break
        end

	end
	if isempty(recorded_list)
		mlevel = level
	else
    	mlevel = maximum([lss[i].decision_level for i in recorded_list])
	end
    return var_queue[1], mlevel, recorded_list, !lss[var_queue[1]].value, cl_num
end

# TODO: Not dry!!!!
function unit_resolution!(problem::SATProblem, lss::Vector{LiteralStatus}, level::Int, undefined_variable_num::Vector{Int})
	while true
		unit_clause_num = findfirst(==(1), undefined_variable_num)
		if isnothing(unit_clause_num)
			break
		end
		unit_clause = problem.clauses[unit_clause_num]
		unit_literal = 0
		parents = Int[]

		for i in unit_clause.true_literals ∪ unit_clause.false_literals
			if lss[i].decision_level >= 0
				parents = parents ∪ i
			else
				unit_literal = i
			end
		end
		unit_value = unit_literal ∈ unit_clause.true_literals
        undefined_variable_num[unit_clause_num] = -1
		lss, undefined_variable_num = decide_literal!(problem, lss, level, undefined_variable_num, unit_value, unit_literal, parents,unit_clause_num)
	end
	return lss, undefined_variable_num
end

function decide_literal!(problem::SATProblem, lss::Vector{LiteralStatus}, level::Int, undefined_variable_num::Vector{Int},b::Bool,lit_num::Int,parents::Vector{Int},dc::Int)
    lss[lit_num] = LiteralStatus(b, level, parents,dc)
    for i in 1:length(problem.clauses)
		cl = problem.clauses[i]
        if undefined_variable_num[i] == -1
			undefined_variable_num[i] = update_uvn(cl, lss)
            # if (lit_num in cl.true_literals && (!b)) || (lit_num in cl.false_literals && (b))
			# 	undefined_variable_num[i] = length(cl.true_literals) + length(cl.false_literals)
			# 	for j in cl.true_literals ∪ cl.false_literals
			# 		ib = j in cl.true_literals
			# 		if lss[j].decision_level >=0 
			# 			if lss[j].value == ib
			# 				undefined_variable_num[i] = -1
			# 				break
			# 			end
			# 			undefined_variable_num[i] -= 1
			# 		end
			# 	end
			# end
        elseif (lit_num in cl.true_literals) && (!b) || (lit_num in cl.false_literals) && (b)
            undefined_variable_num[i] -= 1
        elseif (lit_num in cl.true_literals) && (b) || (lit_num in cl.false_literals) && (!b)
            undefined_variable_num[i] = -1
        end
    end
    return lss, undefined_variable_num
end

function decide_literal_with_unit_resolution!(problem::SATProblem, lss::Vector{LiteralStatus}, level::Int, undefined_variable_num::Vector{Int},b::Bool,lit_num::Int,parents::Vector{Int},dc::Int)
    lss, undefined_variable_num = decide_literal!(problem, lss, level, undefined_variable_num, b, lit_num, parents,dc::Int)
    return unit_resolution!(problem, lss, level, undefined_variable_num)
end

function print_state(lss,undefined_variable_num,level)
	@show level
	@show getfield.(lss,:value)
	@show undefined_variable_num
	@show getfield.(lss,:decision_level)
	@show getfield.(lss,:decision_parents)
end

function update_uvn(cl::SATClause, lss::Vector{LiteralStatus})
	res = length(cl.true_literals) + length(cl.false_literals)
	for j in cl.true_literals ∪ cl.false_literals
		ib = j in cl.true_literals
		if lss[j].decision_level >=0 
			if lss[j].value == ib
				res = -1
				break
			end
			res -= 1
		end
	end
	return res
end

function max_level(lss::Vector{LiteralStatus})
	return maximum([x.decision_level for x in lss])
end