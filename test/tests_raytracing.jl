using Test
using SequentialRaytrace

@testset "Raytracing" begin
    X = 0.0
    Y = 0.0

    ray = make_ray(0.0, 20.0, 0.0, X, Y, sqrt(1.0 - X^2 - Y^2))
    @testset "paraxial surface x" begin
        lens = make_lens(
            "",
            object(air, 200.0),
            [
                optical_component(:base, :meta, [paraxial(150.5, nothing, air, 0.0)])
            ]
        )
        result = gen_result(Vector{Ray}, lens)
        @test trace!(result, lens, ray, 1.0)[end] ≈ make_ray(0.0, 20.0, 0.0, 0.0, -0.1317322700, 0.9912853318) atol=0.00000000001

        ray2 = ray_from_NA(0.0, 0.1)
        r = trace!(result, lens, ray2, 1.0)
        @test r[end] ≈ make_ray(0.0, 20.100756305, 0.0, 0.0, -0.0330380156, 0.9994540958) atol=0.000000001
        y = r[end].y
        cy = r[end].cy
        cz = r[end].cz
        sl = cy / cz
        @test -y/sl ≈ 608.081 atol=1e-3
    end


    ray = make_ray(5.0, 20.0, 0.0, X, Y, sqrt(1.0 - X^2 - Y^2))
    @testset "without raytracing errors" begin
        lens = make_lens(
            "",
            object(air, 200.0),
            [
                optical_component(:c1, :meta1, [
                    sphere(1/50, nothing, silica, 15.0)
                    even_asphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, nothing, air, 35.0)
                ]),
                optical_component(:c2, "meta2", [
                    plano(nothing, air, 10.0)
                    paraxial(-120.3, nothing, air, 30.0)
                ])
            ]
        )
        result = gen_result(Vector{Ray}, lens)
        @test trace!(result, lens, ray, 1.0)[end] ≈ make_ray(-4.0353445, -16.1413780, 0.0, -0.103684, -0.4147364, 0.90401511) atol=0.000001
    end

    X = 0.1
    Y = -0.1
    ray = make_ray(0.0, 20.0, 0.0, X, Y, sqrt(1.0 - X^2 - Y^2))
    @testset "with raytracing errors" begin
        lens = make_lens(
            "",
            object(air, 200.0),
            [
                optical_component(
                    :base,
                    nothing,
                    [
                        sphere(1/50, ClearDiameter(2 * sqrt(40.0^2 + 40.0^2)), silica, 15.0)
                        even_asphere(-1/50, 0.0, 1e-7, 1e-9, 0.0, ClearDiameter(2 * sqrt(20.0^2 + (-1.0)^2)), air, 35.0)
                        plano(nothing, air, 15.0)
                        plano(ClearDiameter(2 * sqrt(10.0^2 + 10.0^2)), air, 15.0)
                    ]
                )
            ]
        )
        result = gen_result(Vector{Ray}, lens)
        @test iserror(trace!(result, lens, ray, 1.0))
        @test trace!(result, lens, ray, 1.0).data[3] ≈ make_ray(20.189725, -1.065485, -4.184919, -0.313750, -0.082502, 0.945914) atol=0.000001
        @test !isassigned(trace!(result, lens, ray, 1.0).data, 4)
        @test iserror(trace!(result, lens, make_ray(0.0, 0.0, 0.0, X, Y, 1 - X^2 - Y^2), 1.0))
        @test error_type(trace!(result, lens, make_ray(0.0, 0.0, 0.0, X, Y, 1 - X^2 - Y^2), 1.0)) === :ray_miss
    end
end
