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

import Base: promote_rule, convert

struct OpticalSurface{T <: Real}
    surface :: AbstractSurface{T}
    aperture :: Union{Clear_Diameter{T}, Nothing}
    n :: AbstractMedium{T}
    t :: T
    id :: Union{Symbol, Nothing}
end

promote_rule(::Type{OpticalSurface{T1}}, ::Type{OpticalSurface{T2}}) where T1 where T2 = OpticalSurface{promote_type(T1, T2)}

function with_fieldtype(t, :: Nothing)
    nothing
end

function convert(::Type{OpticalSurface{T}}, x :: OpticalSurface) where T
    OpticalSurface(
        with_fieldtype(T, x.surface),
        with_fieldtype(T, x.aperture),
        with_fieldtype(T, x.n),
        convert(T, x.t),
        x.id
    )
end

include("Sphere.jl")
include("EvenAsphere.jl")
include("Paraxial.jl")

