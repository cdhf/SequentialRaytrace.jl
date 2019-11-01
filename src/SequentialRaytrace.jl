module SequentialRaytrace

include("Dispersion.jl")
include("Ray.jl")

import ResultTypes: Result, ErrorResult, iserror, unwrap, unwrap_error

include("Surfaces.jl")
include("Lens.jl")

function testlens() 
        Lens(Object(air, 200.0),
                      [
                        sphere(1/50, Unlimited(), silica, 15.0, :first_surface)
                        #= sphere(-1/50, Unlimited(), air, 65) =#
                        even_asphere(-1/50, 0.0, 0.0, 0.0, 0.0, Unlimited(), air, 65.0)
                      ]
                      )
end

function test2()
        x = 0.0
        y = 20.0
        z = 0.0
        X = 0.1
        Y = -0.1
        Z = sqrt(1.0 - X^2 - Y^2)
        ray = Ray(x, y, z, X, Y, Z)
        lens = testlens()
        result = gen_result(lens)
        r1 = trace(lens, ray, 1.0, result, set_ray)
        change_lens(lens)
        result = gen_result(lens)
        r2 = trace(lens, ray, 1.0, result, set_ray)
        (unwrap(r1)[end], unwrap(r2)[end])
end

function change_lens(lens)
        lens.surfaces[1] = sphere(1/40, Unlimited(), silica, 15.0)
end

function test1()
    x = 0.0
    y = 20.0
    z = 0.0
    X = 0.1
    Y = -0.1
    Z = sqrt(1.0 - X^2 - Y^2)
    ray = Ray(x, y, z, X, Y, Z)
    lens = testlens()
    for i in 1:1_000_000
        change_lens(lens)
        result = gen_result(lens)
        trace(lens, ray, 1.0, result, set_ray)
    end
end

function test3()
    x = 0.0
    y = 20.0
    z = 0.0
    X = 0.1
    Y = -0.1
    Z = sqrt(1.0 - X^2 - Y^2)
    ray = Ray(x, y, z, X, Y, Z)
    lens = testlens()
    result = gen_result(lens)
    for i in 1:1_000_000
        #change_lens(lens)
        trace(lens, ray, 1.0, result, set_ray)
    end
end

end # module
