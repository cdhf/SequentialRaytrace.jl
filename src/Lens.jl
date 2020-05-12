struct Object{T}
    n :: AbstractMedium{T}
    t :: T
    function Object(n, t)
        typ = promote_type(fieldtypes(typeof(n))...,
                           typeof(t))
        n2 = with_fieldtype(typ, n)
        t2 = convert(typ, t)
        new{typeof(t2)}(n2, t2)
    end
end


function with_fieldtype(t, x :: Object)
    Object(with_fieldtype(t, x.n,), convert(t, x.t))
end


function Base.convert(::Type{Object{T}}, x :: Object) where T
    Object(
        with_fieldtype(T, x.n),
        convert(T, x.t)
    )
end


struct Lens{T <: Real}
    name :: Any
    object :: Object{T}
    components :: Vector{OpticalComponent{T}}
    function Lens(name, object, components)
        if !allunique([c.id for c in components])
            error("component IDs must be all unique")
        end
        typ = promote_type(
            typeof(object.t),
            typeof(components[1].surfaces[1].t))
        new{typ}(name, with_fieldtype(typ, object), convert(Vector{OpticalComponent{typ}}, components))
    end
end


function track_length(l :: Lens{T}) where T
    sum(map(c -> track_length(c), l.components))
end
