@testset "Raytracing" begin
    X = 0.1
    Y = -0.1
    ray = Ray(0.0, 20.0, 0.0, X, Y, sqrt(1.0 - X^2 - Y^2))

    @testset "without raytracing errors" begin
        # only spherical surfaces
        lens = Lens(Object(air, 200.0),
                    [
                     sphere(1/50, Unlimited(), silica, 15.0)
                     sphere(-1/50, Unlimited(), air
, 65.0)
                    ]
                )
        @test unwrap(trace(lens, ray, 1.0))[end] ≈ Ray(-3.913794,-7.082669,0.0,-0.327602,-0.081838,0.941265) atol=0.000001

        # also even aspheres
        lens = Lens(Object(air, 200.0),
                    [
                     sphere(1/50, Unlimited(), silica, 15.0)
                     even_asphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, Unlimited(), air, 65.0)
                    ]
                   )
        @test unwrap(trace(lens, ray, 1.0))[end] ≈ Ray(-2.758260, -7.099784, 0.0, -0.313750, -0.082502, 0.945914) atol=0.000001
    
        # and dummy surfaces
        lens = Lens(Object(air, 200.0),
                    [
                     sphere(1/50, Unlimited(), silica, 15.0)
                     even_asphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, Unlimited(), air, 35.0)
                     plano(Unlimited(), air, 30.0)
                    ]
                   )
        @test unwrap(trace(lens, ray, 1.0))[end] ≈ Ray(-2.758260, -7.099784, 0.0, -0.313750, -0.082502, 0.945914) atol=0.000001
    end

    @testset "with raytracing errors" begin
        lens = Lens(Object(air, 200.0),
                    [
                     sphere(1/50, 2 * sqrt(40.0^2 + 40.0^2), silica, 15.0)
                     even_asphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, 2 * sqrt(20.0^2 + (-1.0)^2), air, 35.0)
                     plano(Unlimited(), air, 15.0)
                     plano(2 * sqrt(10.0^2 + 10.0^2), air, 15.0)
                    ]
                   )
        @test iserror(trace(lens, ray, 1.0))
        @test length((unwrap_error(trace(lens, ray, 1.0))).data) == 3
        @test (unwrap_error(trace(lens, ray, 1.0))).data[end] ≈ Ray(20.189725, -1.065485, -4.184919, -0.313750, -0.082502, 0.945914) atol=0.000001
        @test unwrap_error(trace(lens, Ray(0.0, 0.0, 0.0, X, Y, 1 - X^2 - Y^2), 1.0)).error_type == :ray_miss
    end
end
