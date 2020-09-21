# only for internal use to avoid allocations
mutable struct InternalRay{T<:Real}
    x::T
    y::T
    z::T
    cx::T
    cy::T
    cz::T
    _e1::T
end

"""
A Ray described by its (x, y, z) coordinates and the
direction cosines (cx, cy, cz). The constructor ensures, that the
relation cx^2 + cy^2 + cz^2 == 1 holds.
"""
struct Ray{T<:Real}
    x::T
    y::T
    z::T
    cx::T
    cy::T
    cz::T
    function Ray(a, b, c, d, e)
        (x, y, z, l, m) = promote(a, b, c, d, e)
        return new{typeof(x)}(x, y, z, l, m, sqrt(1 - l^2 - m^2))
    end
end

function to_internal(t, ray::Ray)
    InternalRay(
        convert(t, ray.x),
        convert(t, ray.y),
        convert(t, ray.z),
        convert(t, ray.cx),
        convert(t, ray.cy),
        convert(t, ray.cz),
        zero(t),
    )
end


"""
    ray_from_NA(y, NA)

Create a Ray in the tangential plane with ray height y and direction cosine in y given by NA
"""
function ray_from_NA(y, NA)
    return Ray(zero(y), y, zero(y), zero(y), NA)
end

# extends ≈ operator
function Base.isapprox(ray1::Ray, ray2::Ray; kwargs...)
    isapprox(ray1.x, ray2.x; kwargs...) &&
        isapprox(ray1.y, ray2.y; kwargs...) &&
        isapprox(ray1.z, ray2.z; kwargs...) &&
        isapprox(ray1.cx, ray2.cx; kwargs...) &&
        isapprox(ray1.cy, ray2.cy; kwargs...) &&
        isapprox(ray1.cz, ray2.cz; kwargs...)
end
