export Lens, Object, trace

struct OpticalComponent
    surfaces :: Array{OpticalSurface}
end

struct Object{T}
    n :: AbstractMedium{T}
    t :: T
end

struct Lens{T <: Real}
    object :: Object{T}
    surfaces :: Array{OpticalSurface{T}}
end

function transfer_to_plane(ray, t)
    (r, e) = transfer_to_intersection(ray, t, Sphere(zero(t)))
    r
end

function gen_result(lens)
    Array{Ray}(undef, 2 + length(lens.surfaces))
end

function update_result!(result :: Array{Ray, 1}, index, _symbol, ray)
    result[index] = ray
    return result
end

"""
trace(lens, ray, wavelength, result)

lens :: Lens
ray :: Ray
wavelength :: Real
result :: something that has an update_result! function
"""
function trace(lens, ray, wavelength, result)
    result = update_result!(result, 1, :object, ray)

    ray_at_s1 = trace_to_s1(lens, ray, wavelength, result)
    after_surfaces = trace_surfaces(ray_at_s1, lens, wavelength, result)
    trace_to_image(lens, after_surfaces, result)

end

function trace_surfaces(err :: RaytraceError, _lens, _wavelength, _result)
    err
end

function trace_surfaces(ray_at_s1, lens, wavelength, result)
    ray_before = ray_at_s1
    index = 3
    for i in 2:length(lens.surfaces)
        s_before = lens.surfaces[i-1]
        s = lens.surfaces[i]
        ray_after = transfer_and_refract(ray_before, s_before.n, s_before.t, s.surface, s.n, wavelength)
        if iserror(ray_after)
            return RaytraceError(ray_after, result)
        end
        if !is_vignetted(ray_after, s.aperture)
            update_result!(result, index, s.id, ray_after)
            index = index + 1
            ray_before = ray_after
        else
            update_result!(result, index, s.id, ray_after)
            resize!(result, index)
            return RaytraceError(vignettedError(), result)
        end
    end
    s_last = lens.surfaces[end]
    (ray_before, index, s_last)
end

function trace_to_s1(lens, ray, wavelength, result)
    s1 = lens.surfaces[1]
    ray_at_s1 = transfer_and_refract(ray, lens.object.n, lens.object.t, s1.surface, s1.n, wavelength)
    if iserror(ray_at_s1)
        return RaytraceError(ray_at_s1.error_type, result)
    end
    update_result!(result, 2, s1.id, ray_at_s1)
    ray_at_s1
end

function trace_to_image(lens, (ray_before, index, s_last), result)
    ray_after = transfer_to_plane(ray_before, s_last.t)
    update_result!(result, index, s_last.id, ray_after)
    return result
end

function trace_to_image(lens, after_surfaces :: RaytraceError, result)
    after_surfaces
end
