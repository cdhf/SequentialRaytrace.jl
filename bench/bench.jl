using BenchmarkTools
using SequentialRaytrace
import SequentialRaytrace: gen_result, update_result!
using TimerOutputs

function testlens()
    Lens("", Object(Air, 200.0),
         [
             OpticalComponent(:a, Nothing, nothing, [
                 Sphere(1/50, nothing, Silica, 15.0, :first_surface)
                 EvenAsphere(-1/50, 0.0, 0.0, 0.0, 0.0, nothing, Air, 65.0)
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
                 Plano(nothing, Silica, 15.0 )
                 Plano(nothing, Air, 15.0 )
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

    Ray(x, y, z, X, Y)
end

function test()
    x = 0.0
    y = 20.0
    z = 0.0
    X = 0.1
    Y = -0.1

    Z = sqrt(1.0 - X^2 - Y^2)
    ray = make_ray(x, y, z, X, Y, Z)
    lens = testlens()
    result = gen_result(Vector{Ray}, lens)
    r1 = trace!(result, lens, ray, 1.0)
    change_lens(lens)
    result = gen_result(Vector{Ray}, lens)
    r2 = trace!(result, lens, ray, 1.0)
    (r1, r2)
    # (unwrap(r1)[end], unwrap(r2)[end])
end

const to = TimerOutput()

function warmup()
    lens = testlens()
    ray = testray()
    result = gen_result(Vector{Ray}, lens)
    trace!(result, lens, ray, 1.0)
end

function timeit()
    lens = testlens()
    ray = testray()
    result = gen_result(Vector{Ray}, lens)
    @timeit to "trace!" trace!(result, lens, ray, 1.0)
end

function bench1()
    lens = testlens()
    ray = testray()
    result = gen_result(Vector{typeof(ray)}, lens)
    @benchmark trace!($result, $lens, $ray, 1.0)
end

function run2(lens, ray)
    result = gen_result(Vector{typeof(ray)}, lens)
    trace!(result, lens, ray, 1.0)
end

function bench2()
    lens = testlens()
    ray = testray()
    @benchmark run2($lens, $ray)
end

function timeit_xx()
    @timeit to "testlens" lens = testlens()
    @timeit to "testray" ray = testray()
    @timeit to "genresult" result = gen_result(Vector{typeof(ray)}, lens)
    @timeit to "trace!" trace!(result, lens, ray, 1.0)
end

function run2b()
    lens = testlens()
    ray = testray()
    result = gen_result(Vector{typeof(ray)}, lens)
    trace!(result, lens, ray, 1.0)
end

function bench2b()
    @benchmark run2b()
end

function gen_result(::Type{Array{T, 2}}, lens) where T
    Array{T, 2}(undef, 6, 2 + SequentialRaytrace.n_surfaces(lens))
    # Array{T, 2}(undef, 2 + SequentialRaytrace.n_surfaces(lens), 6)
end

function update_result!(result :: Array{T, 2}, index, _symbol, ray) where T
    result[1, index] = ray.x
    result[2, index] = ray.y
    result[3, index] = ray.z
    result[4, index] = ray.cx
    result[5, index] = ray.cy
    result[6, index] = ray.cz
    # result[index, 1] = ray.x
    # result[index, 2] = ray.y
    # result[index, 3] = ray.z
    # result[index, 4] = ray.cx
    # result[index, 5] = ray.cy
    # result[index, 6] = ray.cz
    return result
end

function bench3()
    lens = testlens()
    ray = testray()
    result = gen_result(Array{typeof(ray.x), 2}, lens)
    @benchmark trace!($result, $lens, $ray, 1.0)
end

function run4(lens, ray)
    result = gen_result(Array{typeof(ray.x), 2}, lens)
    trace!(result, lens, ray, 1.0)
end

function bench4()
    lens = testlens()
    ray = testray()
    @benchmark run4($lens, $ray)
end



struct OnlyLast{T}
    d :: Array{T, 1}
end

function gen_result(::Type{OnlyLast{T}}, lens) where T
    OnlyLast(Array{T, 1}(undef, 6))
end

function update_result!(result :: OnlyLast{T}, _index, _symbol, ray) where T
    result.d[1] = ray.x
    result.d[2] = ray.y
    result.d[3] = ray.z
    result.d[4] = ray.cx
    result.d[5] = ray.cy
    result.d[6] = ray.cz
    return result
end

function benchb()
    lens = testlens()
    ray = testray()
    result = gen_result(OnlyLast{typeof(ray.x)}, lens)
    @benchmark for i in range(1, stop=100000) trace!($result, $lens, $ray, 1.0) end
end

function timeit4b()
    @timeit to "testlens" lens = testlens()
    @timeit to "testray" ray = testray()
    @timeit to "genresult" result = gen_result(OnlyLast{typeof(ray.x)}, lens)
    @timeit to "trace!" trace!(result, lens, ray, 1.0)
end


function change_lens(lens)
    lens.components[1].surfaces[1] = sphere(1/40, nothing, Silica, 15.0)
end
