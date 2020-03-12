using Test
using SequentialRaytrace

@testset "Promotion" begin
    # all these tests should not throw
    @test object(air, 200) != 0
    @test object(silica, 200) != 0
    @test sphere(0, nothing, silica, 100) != 0
    @test sphere(0, ClearDiameter(10), silica, 100) != 0
    @test paraxial(100, ClearDiameter(10), silica, 100) != 0
    @test even_asphere(0, 1, 1, 1, 1,  ClearDiameter(10), silica, 100) != 0
    @test optical_component(:base, Nothing, "meta data", [
        sphere(0, nothing, ConstantIndex(1), 15),
        even_asphere(-1/50, 0.0, 0.0, 0.0, 0.0, nothing, air, 65.0)]) != 0

    # does not throw
    @test optical_component(:a,
                            Nothing,
                            nothing,
                            [plano(nothing, air, 1.2, :a),
                             plano(nothing, air, 1.2, :b),
                             plano(nothing, air, 1.2, nothing)]) != 0

    @test_throws ErrorException optical_component(:a,
                                                  Nothing,
                                                  nothing,
                                                  [plano(nothing, air, 1.2, :a),
                                                   plano(nothing, air, 1.2, :a),
                                                   plano(nothing, air, 1.2, nothing)])

    @test_throws ErrorException make_lens("",
                                          object(air, 200),
                                          [optical_component(:a, Nothing, nothing, [plano(nothing, air, 1.2)]),
                                           optical_component(:a, Nothing, nothing, [plano(nothing, air, 2.2)])]
                                          )
end
