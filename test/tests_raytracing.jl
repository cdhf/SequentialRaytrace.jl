@testset "Raytracing" begin
    X = 0.0
    Y = 0.0

    ray = Ray(0.0, 20.0, 0.0, X, Y, sqrt(1.0 - X^2 - Y^2))
    @testset "paraxial surface x" begin
        lens = Lens(Object(air, 200.0),
                    [
                        paraxial(150.5, Unlimited(), air, 0)
                    ]
                    )
        result = SequentialRaytrace.gen_result(lens)
        @test unwrap(trace(lens, ray, 1.0, result, SequentialRaytrace.set_ray))[end] ≈ Ray(0.0, 20.0, 0.0, 0.0, -0.13173227, 0.99128533) atol=0.000001
    end


    ray = Ray(5.0, 20.0, 0.0, X, Y, sqrt(1.0 - X^2 - Y^2))
    @testset "without raytracing errors" begin
        lens = Lens(Object(air, 200.0),
                    [
                        sphere(1/50, Unlimited(), silica, 15.0)
                        even_asphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, Unlimited(), air, 35.0)
                        plano(Unlimited(), air, 10.0)
                        paraxial(-120.3, Unlimited(), air, 30)
                    ]
                    )
        result = SequentialRaytrace.gen_result(lens)
        @test unwrap(trace(lens, ray, 1.0, result, SequentialRaytrace.set_ray))[end] ≈ Ray(-4.0353445, -16.1413780, 0.0, -0.103684, -0.4147364, 0.90401511) atol=0.000001
    end

    X = 0.1
    Y = -0.1
    ray = Ray(0.0, 20.0, 0.0, X, Y, sqrt(1.0 - X^2 - Y^2))
    @testset "with raytracing errors" begin
        lens = Lens(Object(air, 200.0),
                    [
                        sphere(1/50, Clear_Diameter(2 * sqrt(40.0^2 + 40.0^2)), silica, 15.0)
                        even_asphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, Clear_Diameter(2 * sqrt(20.0^2 + (-1.0)^2)), air, 35.0)
                        plano(Unlimited(), air, 15.0)
                        plano(Clear_Diameter(2 * sqrt(10.0^2 + 10.0^2)), air, 15.0)
                    ]
                    )
        result = SequentialRaytrace.gen_result(lens)
        @test iserror(trace(lens, ray, 1.0, result, SequentialRaytrace.set_ray))
        @test length((unwrap_error(trace(lens, ray, 1.0, result, SequentialRaytrace.set_ray))).data) == 3
        @test (unwrap_error(trace(lens, ray, 1.0, result, SequentialRaytrace.set_ray))).data[end] ≈ Ray(20.189725, -1.065485, -4.184919, -0.313750, -0.082502, 0.945914) atol=0.000001
        @test unwrap_error(trace(lens, Ray(0.0, 0.0, 0.0, X, Y, 1 - X^2 - Y^2), 1.0, result, SequentialRaytrace.set_ray)).error_type == :ray_miss
    end
end
