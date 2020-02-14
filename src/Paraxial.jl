"""
Zemax paraxial surface
"""
struct Paraxial{T} <: AbstractSurface{T}
    focal_length :: T
end

function with_fieldtype(t, x :: Paraxial)
    Paraxial(convert(t, x.focal_length))
end

function paraxial(focal_length, aperture, n, t)
    OpticalSurface(Paraxial(focal_length), aperture, n, t, nothing)
end

function paraxial(focal_length, aperture, n, t, id)
    OpticalSurface(Paraxial(focal_length), aperture, n, t, id)
end

export paraxial

function sag(x, y, s :: Paraxial)
    return(zero(x))
end

# Raytrace für sphärische Flächen
function transfer_to_intersection(ray, t, s :: Paraxial)
    return(transfer_to_intersection(ray, t, Sphere(zero(t))))
end

function refract((ray, E1), m0, s :: Paraxial, m1, wavelength)
    l = ray.cx
    m = ray.cy
    n = ray.cz
    ux = l / n
    uy = m / n

    n0 = refractive_index(m0, wavelength)
    n1 = refractive_index(m1, wavelength)
    phi = one(s.focal_length) / s.focal_length

    ux_prime = (n0 * ux - ray.x * phi) / n1
    uy_prime = (n0 * uy - ray.y * phi) / n1

    n_prime = sqrt(one(ray.x)/(one(ray.x) + ux_prime^2 + uy_prime^2))
    l_prime = ux_prime * n_prime
    m_prime = uy_prime * n_prime

    Ray(ray.x, ray.y, ray.z, l_prime, m_prime ,n_prime)
end
