"""
This is the parent type for all surfaces. Surfaces
are purely a geometrical abstraction.
"""
abstract type AbstractSurface{T<:Real} end

abstract type AbstractRotationalSymmetricSurface{T} <: AbstractSurface{T} end

function sag(x, y, s::AbstractRotationalSymmetricSurface)
    radius = sqrt(x^2 + y^2)
    return (sag(radius, s))
end


function transfer_and_refract(ray, n1, t, s::AbstractSurface, n2, λ)
    transfered = transfer_to_intersection!(ray, t, s)
    if iserror(transfered)
        return transfered
    else
        refracted = refract!(transfered, n1, s, n2, λ)
        return refracted
    end
end


struct OpticalSurface{T<:Real}
    surface::AbstractSurface{T}
    aperture::Union{ClearDiameter{T},Nothing}
    n::AbstractMedium{T}
    t::T
    id::Union{Symbol,Nothing}
end


Base.promote_rule(
    ::Type{OpticalSurface{T1}},
    ::Type{OpticalSurface{T2}},
) where {T1} where {T2} = OpticalSurface{promote_type(T1, T2)}


convert_fields(t, ::Nothing) = nothing


function Base.convert(::Type{OpticalSurface{T}}, x::OpticalSurface) where {T}
    OpticalSurface(
        convert_fields(T, x.surface),
        convert_fields(T, x.aperture),
        convert_fields(T, x.n),
        convert(T, x.t),
        x.id,
    )
end
