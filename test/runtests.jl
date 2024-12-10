using SATSolvers
using Test

@testset "sat.jl" begin
    include("sat.jl")
end

@testset "solvers.jl" begin
    include("solvers.jl")
end
