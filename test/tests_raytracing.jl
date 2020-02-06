@testset "Raytracing" begin
    X = 0.0
    Y = 0.0

    ray = Ray(0.0, 20.0, 0.0, X, Y, sqrt(1.0 - X^2 - Y^2))
    @testset "paraxial surface x" begin
        lens = Lens(Object(air, 200.0),
                    [
                        OpticalComponent([paraxial(150.5, nothing, air, 0.0)])
                    ]
                    )
        result = SequentialRaytrace.gen_result(lens)
        @test trace(lens, ray, 1.0, result)[end] ≈ Ray(0.0, 20.0, 0.0, 0.0, -0.1317322700, 0.9912853318) atol=0.00000000001

        ray2 = ray_from_NA(0.0, 0.1)
        r = trace(lens, ray2, 1.0, result)
        @test r[end] ≈ Ray(0.0, 20.100756305, 0.0, 0.0, -0.0330380156, 0.9994540958) atol=0.000000001
        y = r[end].y
        cy = r[end].cy
        cz = r[end].cz
        sl = cy / cz
        @test -y/sl ≈ 608.081 atol=1e-3
    end


    ray = Ray(5.0, 20.0, 0.0, X, Y, sqrt(1.0 - X^2 - Y^2))
    @testset "without raytracing errors" begin
        lens = Lens(Object(air, 200.0),
                    [
                        OpticalComponent([
                            sphere(1/50, nothing, silica, 15.0)
                            even_asphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, nothing, air, 35.0)
                        ])
                        , OpticalComponent([
                            plano(nothing, air, 10.0)
                            paraxial(-120.3, nothing, air, 30.0)
                        ])
                    ]
                    )
        result = SequentialRaytrace.gen_result(lens)
        @test trace(lens, ray, 1.0, result)[end] ≈ Ray(-4.0353445, -16.1413780, 0.0, -0.103684, -0.4147364, 0.90401511) atol=0.000001
    end

    X = 0.1
    Y = -0.1
    ray = Ray(0.0, 20.0, 0.0, X, Y, sqrt(1.0 - X^2 - Y^2))
    @testset "with raytracing errors" begin
        lens = Lens(Object(air, 200.0),
                    [
                        OpticalComponent(
                            [
                                sphere(1/50, Clear_Diameter(2 * sqrt(40.0^2 + 40.0^2)), silica, 15.0)
                                even_asphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, Clear_Diameter(2 * sqrt(20.0^2 + (-1.0)^2)), air, 35.0)
                                plano(nothing, air, 15.0)
                                plano(Clear_Diameter(2 * sqrt(10.0^2 + 10.0^2)), air, 15.0)
                            ]
                        )
                    ]
                    )
        result = SequentialRaytrace.gen_result(lens)
        @test iserror(trace(lens, ray, 1.0, result))
        @test trace(lens, ray, 1.0, result).data[3] ≈ Ray(20.189725, -1.065485, -4.184919, -0.313750, -0.082502, 0.945914) atol=0.000001
        @test !isassigned(trace(lens, ray, 1.0, result).data, 4)
        @test iserror(trace(lens, Ray(0.0, 0.0, 0.0, X, Y, 1 - X^2 - Y^2), 1.0, result))
        @test error_type(trace(lens, Ray(0.0, 0.0, 0.0, X, Y, 1 - X^2 - Y^2), 1.0, result)) === :ray_miss
    end
end
