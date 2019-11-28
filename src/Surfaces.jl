export even_asphere, sphere, plano, Unlimited

abstract type AbstractSurface end

struct RaytraceError{T} <: Exception
    error_type :: Symbol
    data :: T
end

include("Sphere.jl")
include("EvenAsphere.jl")

struct Unlimited end

const Clear_Diameter = Union{Float64, Unlimited}

struct OpticalSurface{T, S <: AbstractSurface, M <: AbstractMedium}
    surface :: S
    clear_diameter :: Clear_Diameter
    n :: M
    t :: T
    id :: Union{Symbol, Nothing}
end

function even_asphere(curvature, conic, c4, c6, c8, clear_diameter, n, t)
    OpticalSurface(EvenAsphere(curvature, conic, c4, c6, c8), clear_diameter, n, t, nothing)
end

function even_asphere(curvature, conic, c4, c6, c8, clear_diameter, n, t, id)
    OpticalSurface(EvenAsphere(curvature, conic, c4, c6, c8), clear_diameter, n, t, id)
end

function sphere(curvature, clear_diameter, n, t)
    OpticalSurface(Sphere(curvature), clear_diameter, n, t, nothing)
end

function sphere(curvature, clear_diameter, n, t, id)
    OpticalSurface(Sphere(curvature), clear_diameter, n, t, id)
end

function plano(clear_diameter, n, t)
    sphere(0.0, clear_diameter, n, t, nothing)
end

function plano(clear_diameter, n, t, id)
    sphere(0.0, clear_diameter, n, t, id)
end
