"""
Zemax paraxial surface
"""
struct Paraxial{T <: Real} <: AbstractSurface
    focal_length :: T
end

function sag(x, y, s :: Paraxial)
    return(zero(x))
end

# Raytrace für sphärische Flächen
function transfer_to_intersection(ray, t, s :: Paraxial)
    return(transfer_to_intersection(ray, t, Sphere(0)))
end

function refract((ray, E1), m0, s :: Paraxial, m1, wavelength)
    l = ray.cx
    m = ray.cy
    n = ray.cz
    ux = l / n
    uy = m / n

    n0 = refractive_index(m0, wavelength)
    n1 = refractive_index(m1, wavelength)
    phi = 1 / s.focal_length

    ux_prime = (n0 * ux - ray.x * phi) / n1
    uy_prime = (n0 * uy - ray.y * phi) / n1

    l_prime = ux_prime / sqrt(1 + ux_prime^2 + uy_prime^2)
    m_prime = uy_prime / sqrt(1 + ux_prime^2 + uy_prime^2)
    n_prime = sqrt(1 - l_prime^2 - m_prime^2)

    return(Ray(ray.x, ray.y, ray.z, l_prime, m_prime ,n_prime))
end
