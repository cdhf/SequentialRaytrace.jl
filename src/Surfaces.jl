export even_asphere, sphere, plano, paraxial, Clear_Diameter, Unlimited

abstract type AbstractSurface{T <: Real} end

include("Sphere.jl")
include("EvenAsphere.jl")
include("Paraxial.jl")

struct OpticalSurface{T <: Real}
    surface :: AbstractSurface{T}
    aperture :: Union{Clear_Diameter{T}, Nothing}
    n :: AbstractMedium{T}
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
