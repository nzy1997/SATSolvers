struct BranchSATProblem
	fixed_vars::Vector{Int}
	values::Vector{Bool}
	satproblem::SATProblem
end

literal_count(problem::BranchSATProblem) = literal_count(problem.satproblem)


function remove_literal(cl::SATClause, literal::Int)
	return SATClause(cl.literal_num, setdiff(cl.true_literals, [literal]), setdiff(cl.false_literals, [literal]))
end

function remove_literal(bsp::BranchSATProblem, i::Int, b::Bool)
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

function literal_branching(sp::SATProblem; dpll = false)
	return literal_branching(BranchSATProblem(Int[], fill(false, literal_count(sp)), sp); dpll = dpll)
end

function check_termination(bsp::BranchSATProblem)
	if check_empty_clause(bsp.satproblem)
		return false, [], true
	end
	if length(bsp.satproblem.clauses) == 0
		return true, bsp.values, true
	end
	return [], [], false
end

function literal_branching(bsp::BranchSATProblem; dpll = false)
	dpll && (bsp = unit_resolution(bsp))
	res, ans, term = check_termination(bsp)
	term && return res, ans


	i = setdiff(1:literal_count(bsp), bsp.fixed_vars)[1]

	res, ans = literal_branching(remove_literal(bsp, i, true); dpll)
	if res
		return true, ans
	end

	res, ans = literal_branching(remove_literal(bsp, i, false); dpll)
	if res
		return true, ans
	end
	return false, []
end

# Exact Exponential Algorithm P21 k-sat1
function clause_branching(bsp::BranchSATProblem)
	res, ans, term = check_termination(bsp)
	term && return res, ans

	cl = bsp.satproblem.clauses[1]

	for i in cl.true_literals
		res, ans = clause_branching(remove_literal(bsp, i, true))
		if res
			return true, ans
		end
		bsp = remove_literal(bsp, i, false)
	end


	for i in cl.false_literals
		res, ans = clause_branching(remove_literal(bsp, i, false))
		if res
			return true, ans
		end
		bsp = remove_literal(bsp, i, true)
	end
	return false, []
end

function clause_branching(sp::SATProblem)
	return clause_branching(BranchSATProblem(Int[], fill(false, literal_count(sp)), sp))
end

function unit_resolution(problem::BranchSATProblem)
	while true
		unit_cl = findfirst(cl -> length(cl.true_literals) + length(cl.false_literals) == 1, problem.satproblem.clauses)
		if isnothing(unit_cl)
			break
		end
		unit_cl = problem.satproblem.clauses[unit_cl]
		if isempty(unit_cl.true_literals)
			problem = remove_literal(problem, unit_cl.false_literals[1], false)
		else
			problem = remove_literal(problem, unit_cl.true_literals[1], true)
		end
	end
	return problem
end