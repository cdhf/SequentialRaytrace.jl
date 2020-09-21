using Test
using SequentialRaytrace

@testset "Promotion" begin
    # all these tests should not throw
    @test Object(Air, 200) != 0
    @test Object(Silica, 200) != 0
    @test Sphere(0, nothing, Silica, 100) != 0
    @test Sphere(0, ClearDiameter(10), Silica, 100) != 0
    @test Paraxial(100, ClearDiameter(10), Silica, 100) != 0
    @test EvenAsphere(0, 1, 1, 1, 1, ClearDiameter(10), Silica, 100) != 0
    @test OpticalComponent(
        :base,
        Nothing,
        "meta data",
        [
            Sphere(0, nothing, ConstantIndex(1), 15),
            EvenAsphere(-1 / 50, 0.0, 0.0, 0.0, 0.0, nothing, Air, 65.0),
        ],
    ) != 0

    # does not throw
    @test OpticalComponent(
        :a,
        Nothing,
        nothing,
        [
            Plano(nothing, Air, 1.2, :a),
            Plano(nothing, Air, 1.2, :b),
            Plano(nothing, Air, 1.2, nothing),
        ],
    ) != 0

    @test_throws ErrorException OpticalComponent(
        :a,
        Nothing,
        nothing,
        [
            Plano(nothing, Air, 1.2, :a),
            Plano(nothing, Air, 1.2, :a),
            Plano(nothing, Air, 1.2, nothing),
        ],
    )

    @test_throws ErrorException Lens(
        "",
        Object(Air, 200),
        [
            OpticalComponent(:a, Nothing, nothing, [Plano(nothing, Air, 1.2)]),
            OpticalComponent(:a, Nothing, nothing, [Plano(nothing, Air, 2.2)]),
        ],
    )
end
