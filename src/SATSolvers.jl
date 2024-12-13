module SATSolvers

using StatsBase
using Combinatorics
using Random

export SATProblem,literal_count,clause_count,check_clause,check_answer,SATClause,always_true_clause,random_problem

# dp solvers
export directional_resolution,brute_force,resolve_clause,check_intersections,check_empty_clause

export literal_branching,clause_branching,unit_resolution

# cdcl
export unit_resolution!,first_unique_implication_point,decide_literal!,decide_literal_with_unit_resolution!


include("sat.jl")
include("branching.jl")
include("dpsolvers.jl")
include("cdcl.jl")
end
