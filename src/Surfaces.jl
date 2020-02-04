abstract type AbstractSurface{T <: Real} end

function transfer_and_refract(ray, n1, t, s :: AbstractSurface, n2, wavelength)
    transfered = transfer_to_intersection(ray, t, s)
    if iserror(transfered)
        return transfered
    else
        refracted = refract(transfered, n1, s, n2, wavelength)
        return refracted
    end
end

function transfer_to_intersection(ray, t, s :: AbstractSurface) end
function refract(transferred, m, s :: AbstractSurface, m1, wavelength) end
function sag(x, y, s :: AbstractSurface) end

struct OpticalSurface{T <: Real}
    surface :: AbstractSurface{T}
    aperture :: Union{Clear_Diameter{T}, Nothing}
    n :: AbstractMedium{T}
    t :: T
    id :: Union{Symbol, Nothing}
end

include("Sphere.jl")
include("EvenAsphere.jl")
include("Paraxial.jl")

