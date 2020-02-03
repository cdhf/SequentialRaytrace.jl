export Lens, Object, trace

abstract type AbstractComponent end

struct OpticalComponent <: AbstractComponent
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

function update_result(result :: Array{Ray, 1}, index, _symbol, ray)
    result[index] = ray
    return result
end

"""
trace(lens, ray, wavelength, result)

lens :: Lens
ray :: Ray
wavelength :: Real
result :: something that has an update_result function
"""
function trace(lens, ray, wavelength, result :: T) where T
    result = update_result(result, 1, :object, ray)
    s1 = lens.surfaces[1]
    # TODO: missing error handling
    ray_at_s1 = transfer_and_refract(ray, lens.object.n, lens.object.t, s1.surface, s1.n, wavelength)
    if iserror(ray_at_s1)
        return RaytraceError(ray_at_s1.error_type, result)
    end
    result = update_result(result, 2, s1.id, ray_at_s1)

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
            result = update_result(result, index, s.id, ray_after)
            index = index + 1
            ray_before = ray_after
        else
            result = update_result(result, index, s.id, ray_after)
            resize!(result, index)
            return RaytraceError(VignettedError(), result)
        end
    end
    s_last = lens.surfaces[end]
    ray_after = transfer_to_plane(ray_before, s_last.t)
    result = update_result(result, index, s_last.id, ray_after)
    return result
end
