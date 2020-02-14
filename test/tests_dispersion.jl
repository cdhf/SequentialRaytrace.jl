using Test
using SequentialRaytrace

@testset "Dispersion" begin
    @test refractive_index(air, 1.070) ≈ 1.0 atol=1e-10
    @test refractive_index(air, 0.94) ≈ 1.0 atol=1e-10
    @test refractive_index(silica, 1.070) ≈ 1.4495591322295867 atol=1e-18
    @test refractive_index(silica, 0.94) ≈ 1.4511992021095206 atol=1e-18
end
