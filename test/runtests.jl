using SATSolvers
using Test

@testset "sat.jl" begin
    include("sat.jl")
end

@testset "dpsolvers.jl" begin
    include("dpsolvers.jl")
end

@testset "branching.jl" begin
    include("branching.jl")
end

@testset "cdcl.jl" begin
    include("cdcl.jl")
end

@testset "vizcdcl.jl" begin
    include("vizcdcl.jl")
end