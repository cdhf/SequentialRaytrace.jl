"""
id: an identifier that uniquely identifies the component in a lens
meta_data: any additional meta data for this component
surfaces
"""
struct OpticalComponent{T<:Real}
    id::Symbol
    type::DataType
    meta_data::Any
    surfaces::Vector{OpticalSurface{T}}
    function OpticalComponent(
        id,
        type,
        meta_data,
        surfaces::Vector{OpticalSurface{T}},
    ) where {T}
        if !allunique(filter(s -> !isnothing(s.id), surfaces))
            error("Surface IDs must be nothing or unique")
        end
        new{T}(id, type, meta_data, surfaces)
    end
end

Base.promote_rule(
    ::Type{OpticalComponent{T1}},
    ::Type{OpticalComponent{T2}},
) where {T1} where {T2} = OpticalComponent{promote_type(T1, T2)}

function Base.convert(::Type{OpticalComponent{T}}, x::OpticalComponent) where {T}
    OpticalComponent(x.id, x.type, x.meta_data, Vector{OpticalSurface{T}}(x.surfaces))
end

function track_length(oc::OpticalComponent{T}) where {T}
    sum(map(s -> s.t, oc.surfaces))
end

function track_length(os::Vector{OpticalSurface{T}}) where {T}
    sum(map(s -> s.t, os))
end

function track_length(os::Vector{OpticalSurface{T}}, id::Symbol) where {T}
    l = zero(T)
    for s in os
        l += s.t
        if s.id == id
            return l
        end
    end
    nothing
end

function track_length(c::OpticalComponent{T}, id::Symbol) where {T}
    track_length(c.surfaces, id)
end
