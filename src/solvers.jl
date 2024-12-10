function directional_resolution(problem::SATProblem)
    buskets = [geticlauses(i,problem) for i in 1:literal_count(problem)]

    for i in 1:literal_count(problem)
        for (cl1,cl2) in combinations(buskets[i],2)
            if check_intersections(cl1,cl2)
                rcl = resolve_clause(cl1,cl2,i)
                if always_true_clause(rcl)
                    continue
                elseif rcl.true_literals == [] && rcl.false_literals == []
                    return false
                else
                    push!(buskets[minimum(rcl.true_literals ∪ rcl.false_literals)],rcl)
                end
            end
        end
    end
    return true
end

function geticlauses(literal::Int, problem::SATProblem)
    return [x for x in problem.clauses if literal == minimum(x.true_literals ∪ x.false_literals)]
end

function check_intersections(cl1::SATClause, cl2::SATClause)
    return any(x->x ∈ cl1.false_literals, cl2.true_literals) || any(x->x ∈ cl2.false_literals, cl1.true_literals) 
end

function resolve_clause(cl1::SATClause, cl2::SATClause, literal::Int)
    return SATClause(cl1.literal_num,setdiff(cl1.true_literals ∪ cl2.true_literals,literal),setdiff(cl1.false_literals ∪ cl2.false_literals, literal))
end

function brute_force(problem::SATProblem)
    for i in 1:2^literal_count(problem)
        answer = [i & (1 << j) != 0 for j in 1:literal_count(problem)]
        if check_answer(problem, answer)
            return true, answer
        end
    end
    return false, []
end
