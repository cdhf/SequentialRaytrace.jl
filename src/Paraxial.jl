"""
Zemax paraxial surface
"""
struct Paraxial{T} <: AbstractSurface{T}
    focal_length::T
end


function Paraxial(focal_length, aperture, n, t, id = nothing)
    OpticalSurface(
        Paraxial(focal_length),
        aperture,
        n,
        t,
        id,
    )
end


function sag(radius, s::Paraxial)
    return (zero(x))
end


function sag(x, y, s::Paraxial)
    return (zero(x))
end


function transfer_to_intersection!(ray, t, s::Paraxial)
    return (transfer_to_intersection!(ray, t, Sphere(zero(t))))
end


function refract!(ray, m0, s::Paraxial, m1, λ)
    l = ray.cx
    m = ray.cy
    n = ray.cz
    ux = l / n
    uy = m / n

    n0 = refractive_index(m0, λ)
    n1 = refractive_index(m1, λ)
    phi = one(s.focal_length) / s.focal_length

    ux_prime = (n0 * ux - ray.x * phi) / n1
    uy_prime = (n0 * uy - ray.y * phi) / n1

    n_prime = sqrt(one(ray.x) / (one(ray.x) + ux_prime^2 + uy_prime^2))
    l_prime = ux_prime * n_prime
    m_prime = uy_prime * n_prime

    ray.cx = l_prime
    ray.cy = m_prime
    ray.cz = n_prime
    return ray
end
