using Test
using SequentialRaytrace
using LsqFit

function mylens(imageDist)
    t = typeof(imageDist)
    Lens(
        "",
        Object(air, 10.0),
        [
            OpticalComponent(
                :base,
                Nothing,
                nothing,
                [
                    even_asphere(0, 0, 0, 0, 0, ClearDiameter(100), silica, 1.5, :S1),
                    plano(nothing, silica, 1.5),
                    sphere(-1.0/98.3, nothing, air, imageDist, :S2)
                ])
        ]
    )
end

function model(x, p)
    imageDist = p[1]
    t = typeof(imageDist)
    testray = ray_from_NA(0.0, 0.125)
    lens = mylens(imageDist)
    result = gen_result(Vector{Ray{typeof(imageDist)}}, lens)
    r = trace!(result, lens, testray, 1.0)
    r[end].y
end


@testset "LsqFit" begin
    @testset "optimize with automatic derivatives" begin
        xdata = [0.0]
        ydata = [0.0]

        vect_model(x, p) = model.(x, p)
        r = curve_fit(vect_model, xdata, ydata, [10.0], autodiff = :forwarddiff)
        @test r.param[1] ≈ -12.7875519 atol = 1e-7
    end
end
