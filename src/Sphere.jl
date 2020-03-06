struct Sphere{T} <: AbstractRotationalSymmetricSurface{T}
    curvature :: T
end


with_fieldtype(t, x :: Sphere) = Sphere(convert(t, x.curvature))


function sphere(curvature, aperture, n, t, id = nothing)
    typ = promote_type(
        typeof(curvature),
        fieldtypes(typeof(aperture))...,
        fieldtypes(typeof(n))...,
        typeof(t))
    OpticalSurface(Sphere(convert(typ, curvature)), with_fieldtype(typ, aperture), with_fieldtype(typ, n), convert(typ, t), id)
end


plano(aperture, n, t, id = nothing) = sphere(0.0, aperture, n, t, id)

function sag(radius, s :: Sphere)
    radius2 = radius^2
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
        return rayMissError()
    end
    E1 = sqrt(E1Arg)
    L = e + (cv * M1squared - 2 * M1z) / (ray.cz + E1)
    z1 = ray.z + L * ray.cz - t
    y1 = ray.y + L * ray.cy
    x1 = ray.x + L * ray.cx
    (Ray(x1, y1, z1, ray.cx, ray.cy, ray.cz), E1)
end

function refract((ray, E1), m, s :: Sphere, m1, λ)
    if m == m1
        X1 = ray.cx
        Y1 = ray.cy
        Z1 = ray.cz
    else
        n0 = refractive_index(m, λ)
        n1 = refractive_index(m1, λ)
        EprimeArg = 1 - (n0 / n1)^2 * (1 - E1^2)
        if EprimeArg < 0
            return totalInternalReflectionError()
        end
        Eprime = sqrt(EprimeArg)
        g1 = Eprime - n0 / n1 * E1
        Z1 = n0 / n1 * ray.cz - g1 * s.curvature * ray.z + g1
        Y1 = n0 / n1 * ray.cy - g1 * s.curvature * ray.y
        X1 = n0 / n1 * ray.cx - g1 * s.curvature * ray.x
    end
    Ray(ray.x, ray.y, ray.z, X1, Y1, Z1)
end
