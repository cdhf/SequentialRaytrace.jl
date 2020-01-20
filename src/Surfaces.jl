export even_asphere, sphere, plano, paraxial, Clear_Diameter, Unlimited

abstract type AbstractSurface end

struct RaytraceError{T} <: Exception
    error_type :: Symbol
    data :: T
end

include("Sphere.jl")
include("EvenAsphere.jl")
include("Paraxial.jl")

abstract type AbstractAperture end

struct Unlimited <: AbstractAperture end

struct Clear_Diameter{T <: Real} <: AbstractAperture
    clear_diameter :: T
end

function is_vignetted(ray, a :: Unlimited)
    return(false)
end

function is_vignetted(ray, a :: Clear_Diameter)
    ray_height = 2 * sqrt(ray.x^2 + ray.y^2)
    return(ray_height > a.clear_diameter)
end

struct OpticalSurface{T <: Real, S <: AbstractSurface, M <: AbstractMedium, A <: AbstractAperture}
    surface :: S
    aperture :: A
    n :: M
    t :: T
    id :: Union{Symbol, Nothing}
end

function even_asphere(curvature, conic, c4, c6, c8, aperture, n, t)
    OpticalSurface(EvenAsphere(curvature, conic, c4, c6, c8), aperture, n, t, nothing)
end

function even_asphere(curvature, conic, c4, c6, c8, aperture, n, t, id)
    OpticalSurface(EvenAsphere(curvature, conic, c4, c6, c8), aperture, n, t, id)
end

function sphere(curvature, aperture, n, t)
    OpticalSurface(Sphere(curvature), aperture, n, t, nothing)
end

function sphere(curvature, aperture, n, t, id)
    OpticalSurface(Sphere(curvature), aperture, n, t, id)
end

function plano(aperture, n, t)
    sphere(0.0, aperture, n, t, nothing)
end

function plano(aperture, n, t, id)
    sphere(0.0, aperture, n, t, id)
end

function paraxial(focal_length, aperture, n, t)
    OpticalSurface(Paraxial(focal_length), aperture, n, t, nothing)
end

function paraxial(focal_length, aperture, n, t, id)
    OpticalSurface(Paraxial(focal_length), aperture, n, t, id)
end
