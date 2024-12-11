function directional_resolution(problem::SATProblem)
	if check_empty_clause(problem)
		return false,[]
	end
	buskets = [geticlauses(i, problem) for i in 1:literal_count(problem)]

	for i in 1:literal_count(problem)
		for (cl1, cl2) in combinations(buskets[i], 2)
			if check_intersections(cl1, cl2,i)
				rcl = resolve_clause(cl1, cl2, i)
				if always_true_clause(rcl)
					continue
				elseif rcl.true_literals == [] && rcl.false_literals == []
					return false,[]
				else
                    busket_num = minimum(rcl.true_literals ∪ rcl.false_literals)
					push!(buskets[busket_num], rcl)
                    unique!(buskets[busket_num])
				end
			end
		end
	end
	return true,get_answer(problem,buskets)
end

function get_answer(problem::SATProblem,buskets::Vector{Vector{SATClause}})
    answer = [false for i in 1:literal_count(problem)]
    for i in literal_count(problem):(-1):1
        for cl in buskets[i]
            if check_clause(cl, answer)
                continue
            else
                answer[i] = true
                break
            end
        end
    end
    return answer
end

function geticlauses(literal::Int, problem::SATProblem)
	return [x for x in problem.clauses if literal == minimum(x.true_literals ∪ x.false_literals)]
end

function check_intersections(cl1::SATClause, cl2::SATClause, literal::Int)
	return (literal in cl1.false_literals && literal in cl2.true_literals) || (literal in cl1.true_literals && literal in cl2.false_literals)
end

function resolve_clause(cl1::SATClause, cl2::SATClause, literal::Int)
	return SATClause(cl1.literal_num, setdiff(cl1.true_literals ∪ cl2.true_literals, literal), setdiff(cl1.false_literals ∪ cl2.false_literals, literal))
end

function brute_force(problem::SATProblem)
	if check_empty_clause(problem)
		return false, []
	end
	for i in 0:2^literal_count(problem)-1
		answer = [i & (1 << j) != 0 for j in 0:literal_count(problem)-1]
		if check_answer(problem, answer)
			return true, answer
		end
	end
	return false, []
end

function check_empty_clause(pb::SATProblem)
	for cl in pb.clauses
		if cl.true_literals == [] && cl.false_literals == []
			return true
		end
	end
	return false
end
