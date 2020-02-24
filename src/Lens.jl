struct OpticalComponent{T <: Real}
    name :: String
    surfaces :: Vector{OpticalSurface{T}}
end

function track_length(oc :: OpticalComponent{T}) where T
    sum(map(s -> s.t, oc.surfaces))
end

function track_length(os :: Vector{OpticalSurface{T}}) where T
    sum(map(s -> s.t, os))
end

export track_length

export OpticalComponent

struct Object{T}
    n :: AbstractMedium{T}
    t :: T
end

function with_fieldtype(t, x :: Object)
    Object(with_fieldtype(t, x.n,), convert(t, x.t))
end

export Object

struct Lens{T <: Real}
    name :: String
    object :: Object{T}
    components :: Vector{OpticalComponent{T}}
end

function track_length(l :: Lens{T}) where T
    sum(map(c -> track_length(c), l.components))
end

function make_lens(name, object, components)
    typ = promote_type(
        typeof(object.t),
        typeof(components[1].surfaces[1].t))
    Lens(name, with_fieldtype(typ, object), convert(Vector{OpticalComponent{typ}}, components))
end

export make_lens

function transfer_to_plane(ray, t)
    (r, e) = transfer_to_intersection(ray, t, Sphere(zero(t)))
    r
end

n_surfaces(lens :: Lens) = sum(map(c -> length(c.surfaces), lens.components))

function gen_result(lens)
    Array{Ray}(undef, 2 + n_surfaces(lens))
end

export gen_result

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
    wl = convert(typeof(lens.object.t), wavelength)
    ray_c = with_fieldtype(typeof(lens.object.t), ray)
    result = update_result!(result, 1, :object, ray_c)

    index = 2
    n = lens.object.n
    t = lens.object.t

    after_surfaces = trace_components(index, ray_c, n, t, lens.components, wl, result)
    trace_to_image(lens, after_surfaces, result)
end

function trace_components(index, ray, n, t, components, wavelength, result)
    if length(components) > 0
        after_surfaces = trace_component(index, ray, n, t, components[1], wavelength, result)
        for c in components[2:end]
            if iserror(after_surfaces)
                return after_surfaces
            end
            (index, ray_before, n, t) = after_surfaces
            after_surfaces = trace_component(index, ray_before, n, t, c, wavelength, result)
        end
        after_surfaces
    else
        result
    end
end

export trace

function trace_component(index, ray_before, n, t, component, wavelength, result)
    trace_surfaces(index, ray_before, n, t, component.surfaces, wavelength, result)
end

function trace_surfaces(index, ray_before, n, t, surfaces, wavelength, result)
    for i in 1:length(surfaces)
        s = surfaces[i]
        ray_after = transfer_and_refract(ray_before, n, t, s.surface, s.n, wavelength)
        if iserror(ray_after)
            return RaytraceError(ray_after, result)
        end
        update_result!(result, index, s.id, ray_after)
        if !is_vignetted(ray_after, s.aperture)
            index = index + 1
            ray_before = ray_after
            n = s.n
            t = s.t
        else
            return RaytraceError(vignettedError(), result)
        end
    end
    s_last = surfaces[end]
    (index, ray_before, s_last.n, s_last.t)
end

function trace_to_image(lens, (index, ray_before, last_n, last_t), result)
    ray_after = transfer_to_plane(ray_before, last_t)
    update_result!(result, index, :image, ray_after)
    result
end

function trace_to_image(lens, after_surfaces :: RaytraceError, result)
    after_surfaces
end
