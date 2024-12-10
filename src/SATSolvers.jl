module SATSolvers


using Combinatorics
# Write your package code here.
export SATProblem,literal_count,clause_count,check_clause,check_answer,SATClause,always_true_clause


export directional_resolution,brute_force,resolve_clause,check_intersections

include("sat.jl")
include("solvers.jl")
end
