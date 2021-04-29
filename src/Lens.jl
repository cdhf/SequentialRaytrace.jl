struct Object{T}
    n::AbstractMedium{T}
    t::T
end


struct Lens{T<:Real}
    name::Any
    object::Object{T}
    components::AbstractVector{OpticalComponent{T}}
    function Lens(name, object::Object{T}, components) where T
        if !allunique([c.id for c in components])
            error("component IDs must be all unique")
        end
        new{T}(
            name,
            object,
            components,
        )
    end
end


function track_length(l::Lens{T}) where {T}
    sum(map(c -> track_length(c), l.components))
end
