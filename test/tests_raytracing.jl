using Test
using SequentialRaytrace

@testset "Raytracing" begin
    X = 0.0
    Y = 0.0

    ray = Ray(0.0, 20.0, 0.0, X, Y)
    @testset "paraxial surface x" begin
        lens = Lens(
            "",
            Object(Air, 200.0),
            [
                OpticalComponent(:base, Nothing, :meta, [Paraxial(150.5, nothing, Air, 0.0)])
            ]
        )
        result = gen_result(Vector{typeof(ray)}, lens)
        @test trace!(result, lens, ray, 1.0)[end] ≈ Ray(0.0, 20.0, 0.0, 0.0, -0.1317322700) atol=0.00000000001

        ray2 = ray_from_NA(0.0, 0.1)
        r = trace!(result, lens, ray2, 1.0)
        @test r[end] ≈ Ray(0.0, 20.100756305, 0.0, 0.0, -0.0330380156) atol=0.000000001
        y = r[end].y
        cy = r[end].cy
        cz = r[end].cz
        sl = cy / cz
        @test -y/sl ≈ 608.081 atol=1e-3
    end


    ray = Ray(5.0, 20.0, 0.0, X, Y)
    @testset "without raytracing errors" begin
        lens = Lens(
            "",
            Object(Air, 200.0),
            [
                OpticalComponent(:c1, Nothing, :meta1, [
                    Sphere(1/50, nothing, Silica, 15.0)
                    EvenAsphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, nothing, Air, 35.0)
                ]),
                OpticalComponent(:c2, Nothing, "meta2", [
                    Plano(nothing, Air, 10.0)
                    Paraxial(-120.3, nothing, Air, 30.0)
                ])
            ]
        )
        result = gen_result(Vector{typeof(ray)}, lens)
        @test trace!(result, lens, ray, 1.0)[end] ≈ Ray(-4.0353445, -16.1413780, 0.0, -0.103684, -0.4147364) atol=0.000001
    end

    X = 0.1
    Y = -0.1
    ray = Ray(0.0, 20.0, 0.0, X, Y)
    @testset "with raytracing errors" begin
        lens = Lens(
            "",
            Object(Air, 200.0),
            [
                OpticalComponent(
                    :base,
                    Nothing,
                    nothing,
                    [
                        Sphere(1/50, ClearDiameter(2 * sqrt(40.0^2 + 40.0^2)), Silica, 15.0)
                        EvenAsphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, ClearDiameter(2 * sqrt(20.0^2 + (-1.0)^2)), Air, 35.0)
                        Plano(nothing, Air, 15.0)
                        Plano(ClearDiameter(2 * sqrt(10.0^2 + 10.0^2)), Air, 15.0)
                    ]
                )
            ]
        )
        result = gen_result(Vector{typeof(ray)}, lens)
        @test iserror(trace!(result, lens, ray, 1.0))
        @test trace!(result, lens, ray, 1.0).data[3] ≈ Ray(20.189725, -1.065485, -4.184919, -0.313750, -0.082502) atol=0.000001
        @test trace!(result, lens, ray, 1.0).global_index == 3
        @test trace!(result, lens, ray, 1.0).component_id == :base
        @test trace!(result, lens, ray, 1.0).local_index == 2
        @test iserror(trace!(result, lens, Ray(0.0, 0.0, 0.0, X, Y), 1.0))
        ray = Ray(0.0, 20.0, 0.0, X, Y)
        @test error_type(trace!(result, lens, Ray(0.0, 0.0, 0.0, X, Y), 1.0)) === :vignetted
    end

end
