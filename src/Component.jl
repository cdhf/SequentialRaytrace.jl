"""
id: an identifier that uniquely identifies the component in a lens
meta_data: any additional meta data for this component
surfaces
"""
struct OpticalComponent{T<:Real}
    id::Symbol
    type::DataType
    meta_data::Any
    surfaces::AbstractVector{OpticalSurface{T}}
    function OpticalComponent(
        id,
        type,
        meta_data,
        surfaces::AbstractVector{OpticalSurface{T}},
    ) where {T}
        if !allunique(filter(s -> !isnothing(s.id), surfaces))
            error("Surface IDs must be nothing or unique")
        end
        new{T}(id, type, meta_data, surfaces)
    end
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
