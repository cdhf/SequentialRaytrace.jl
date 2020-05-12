function transfer_to_plane(ray, t)
    return transfer_to_intersection!(ray, t, Sphere(zero(t)))
end


function n_surfaces(lens :: Lens)
    return sum(map(c -> length(c.surfaces), lens.components))
end


"""
Rreallocate a result for trace!
"""
function gen_result(::Type{Array{Ray{T}, 1}}, lens :: Lens{T}) where T
    [Ray(zero(T), zero(T), zero(T), zero(T), zero(T)) for i in range(1, stop = 2 + n_surfaces(lens))]
end


"""
Update a result with data from ray tracing and return it
"""
function update_result!(result :: Array{Ray{T}, 1}, index, _symbol, ray) where T
    result[index] = Ray(ray.x, ray.y, ray.z, ray.cx, ray.cy)
    return result
end


"""
trace(lens, ray, wavelength, result)

lens :: Lens
ray :: Ray
wavelength :: Real
result :: something that has an update_result! function
ignore_apertures :: Bool
"""
function trace!(result, lens, ray :: Ray{T}, wavelength; ignore_apertures = false) where T
    wl = convert(typeof(lens.object.t), wavelength)
    ray_c = to_internal(typeof(lens.object.t), ray)
    result = update_result!(result, 1, :object, ray_c)

    global_index = 2
    n = lens.object.n
    t = lens.object.t

    after_surfaces = trace_components!(result, global_index, ray_c, n, t, lens.components, wl, ignore_apertures)
    trace_to_image!(result, lens, after_surfaces)
end


function trace_components!(result, global_index, ray, n, t, components, wavelength, ignore_apertures)
    if length(components) > 0
        after_surfaces = trace_component!(result, global_index, ray, n, t, components[1], wavelength, ignore_apertures)
        for c in components[2:end]
            if iserror(after_surfaces)
                return after_surfaces
            end
            (global_index, ray_before, n, t) = after_surfaces
            after_surfaces = trace_component!(result, global_index, ray_before, n, t, c, wavelength, ignore_apertures)
        end
        after_surfaces
    else
        result
    end
end


function trace_component!(result, global_index, ray_before, n, t, component, wavelength, ignore_apertures)
    trace_surfaces!(result, global_index, component.id, ray_before, n, t, component.surfaces, wavelength, ignore_apertures)
end


function trace_surfaces!(result, global_index, component_id, ray_before, n, t, surfaces, wavelength, ignore_apertures)
    for i in 1:length(surfaces)
        s = surfaces[i]
        ray_after = transfer_and_refract(ray_before, n, t, s.surface, s.n, wavelength)
        if iserror(ray_after)
            return RaytraceError(ray_after, global_index, component_id, i, s.id, result)
        end
        result = update_result!(result, global_index, s.id, ray_after)
        if ignore_apertures || !is_vignetted(ray_after, s.aperture)
            global_index = global_index + 1
            ray_before = ray_after
            n = s.n
            t = s.t
        else
            return RaytraceError(vignetted_error(), global_index, component_id, i, s.id, result)
        end
    end
    s_last = surfaces[end]
    (global_index, ray_before, s_last.n, s_last.t)
end


function trace_to_image!(result, lens, (global_index, ray_before, last_n, last_t))
    ray_after = transfer_to_plane(ray_before, last_t)
    update_result!(result, global_index, :image, ray_after)
end


function trace_to_image!(result, lens, err :: RaytraceError)
    err
end
