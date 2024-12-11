using SATSolvers
using Test

@testset "sat.jl" begin
    include("sat.jl")
end

@testset "dpsolvers.jl" begin
    include("dpsolvers.jl")
end
