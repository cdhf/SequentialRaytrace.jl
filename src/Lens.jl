
export Lens, trace

struct Object{T, M <: AbstractMedium}
	n :: M
	t :: T
end

struct Lens
	object :: Object
	surfaces :: Array{OpticalSurface}
end

function transfer_to_plane(ray, t)
	(r, e) = transfer_to_intersection(ray, t, Sphere(0.0))
	r
end

function gen_result(lens)
	Array{Ray}(undef, 2 + length(lens.surfaces))
end

function set_ray(result, index, ray)
	result[index] = ray
end

function trace(lens, ray, wavelength) :: Result{Array{Ray}, RaytraceError}
	result = gen_result(lens)
	set_ray(result, 1, ray)
	s1 = lens.surfaces[1]
    # TODO: missing error handling
    ray_at_s1 = unwrap(transfer_and_refract(ray, lens.object.n, lens.object.t, s1.surface, s1.n, wavelength))
    set_ray(result, 2, ray_at_s1)

    ray_before = ray_at_s1
	index = 3
	for i in 2:length(lens.surfaces)
		s_before = lens.surfaces[i-1]
		s = lens.surfaces[i]
        ray_after = unwrap(transfer_and_refract(ray_before, s_before.n, s_before.t, s.surface, s.n, wavelength))
		ray_height = 2 * sqrt(ray_after.x^2 + ray_after.y^2)
		if (s.clear_diameter === Unlimited()) || (ray_height <= s.clear_diameter)
			set_ray(result, index, ray_after)
			index = index + 1
			ray_before = ray_after
		else
			set_ray(result, index, ray_after)
			resize!(result, index)
			return(RaytraceError(result, :vignetted))
		end
	end
	s_last = lens.surfaces[end]
	ray_after = transfer_to_plane(ray_before, s_last.t)
	set_ray(result, index, ray_after)
	result
end


