struct Sphere{T} <: AbstractSurface
    curvature :: T
end

function sag(x, y, s :: Sphere)
    radius2 = x^2 + y^2
    return(s.curvature * radius2 / (1 + sqrt(1 - (s.curvature^2 * radius2))))
end

# Raytrace für sphärische Flächen
function transfer_to_intersection(ray, t, s :: Sphere)
    cv = s.curvature
    e = t * ray.cz - (ray.x * ray.cx + ray.y * ray.cy + ray.z * ray.cz)
    M1z = ray.z + e * ray.cz - t
    M1squared = ray.x^2 + ray.y^2 + ray.z^2 - e^2 + t^2 - 2 * t * ray.z
    E1Arg = ray.cz^2 - cv * (cv * M1squared - 2 * M1z)
    if E1Arg < 0
        return RaytraceError(:ray_miss, undef)
    end
    E1 = sqrt(E1Arg)
    L = e + (cv * M1squared - 2 * M1z) / (ray.cz + E1)
    z1 = ray.z + L * ray.cz - t
    y1 = ray.y + L * ray.cy
    x1 = ray.x + L * ray.cx
    (Ray(x1, y1, z1, ray.cx, ray.cy, ray.cz), E1)
end

function refract((ray, E1), m, s :: Sphere, m1, wavelength)
    if m == m1
        X1 = ray.cx
        Y1 = ray.cy
        Z1 = ray.cz
    else
        n0 = refractive_index(m, wavelength)
        n1 = refractive_index(m1, wavelength)
        EprimeArg = 1 - (n0 / n1)^2 * (1 - E1^2)
        if EprimeArg < 0
            return RaytraceError(:total_internal_reflection, undef)
        end
        Eprime = sqrt(EprimeArg)
        g1 = Eprime - n0 / n1 * E1
        Z1 = n0 / n1 * ray.cz - g1 * s.curvature * ray.z + g1
        Y1 = n0 / n1 * ray.cy - g1 * s.curvature * ray.y
        X1 = n0 / n1 * ray.cx - g1 * s.curvature * ray.x
    end
    Ray(ray.x, ray.y, ray.z, X1, Y1, Z1)
end

function transfer_and_refract(ray, n1, t, s, n2, wavelength) :: Result{Ray, RaytraceError}
    # TODO: make generic and dispatch to transfer_to_intersection and refract
    transfered = transfer_to_intersection(ray, t, s)
    if iserror(transfered)
        return transfered
    else
        refracted = refract(unwrap(transfered), n1, s, n2, wavelength)
        if iserror(refracted)
            return refracted
        else
            return refracted
        end
    end
end
