using SequentialRaytrace

function testlens()
    make_lens("", Object(air, 200.0),
         [
             OpticalComponent("", [
                 sphere(1/50, nothing, silica, 15.0, :first_surface)
                 even_asphere(-1/50, 0.0, 0.0, 0.0, 0.0, nothing, air, 65.0)
             ])
         ]
         )
end

function testray()
    x = 0.0
    y = 20.0
    z = 0.0
    X = 0.1
    Y = -0.1

    Z = sqrt(1.0 - X^2 - Y^2)
    Ray(x, y, z, X, Y, Z)
end

function test()
    x = 0.0
    y = 20.0
    z = 0.0
    X = 0.1
    Y = -0.1

    Z = sqrt(1.0 - X^2 - Y^2)
    ray = Ray(x, y, z, X, Y, Z)
    lens = testlens()
    result = gen_result(lens)
    r1 = trace!(result, lens, ray, 1.0)
    change_lens(lens)
    result = gen_result(lens)
    r2 = trace!(result, lens, ray, 1.0)
    (r1, r2)
    # (unwrap(r1)[end], unwrap(r2)[end])
end

function change_lens(lens)
    lens.components[1].surfaces[1] = sphere(1/40, nothing, silica, 15.0)
end
