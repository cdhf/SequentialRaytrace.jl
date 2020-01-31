"""
A Ray described by its (x, y, z) coordinates and the
direction cosines (cx, cy, cz)
"""
struct Ray{T <: Real}
    x :: T
    y :: T
    z :: T
    cx :: T
    cy :: T
    cz :: T
end

export Ray

# some other ways to construct Rays

"""
    ray_from_NA(y :: T, NA :: T) :: Ray{T} where T

Create a Ray in the tangential plane with ray height y and direction cosine in y given by NA
"""
function ray_from_NA(y :: T, NA :: T) :: Ray{T} where T
    return Ray(zero(y), y, zero(y), zero(y), NA, (sqrt(1 - NA^2)))
end

export ray_from_NA

# extend ≈ operator
import Base

function Base.isapprox(ray1 :: Ray, ray2 :: Ray; kwargs...)
    isapprox(ray1.x, ray2.x; kwargs...) &&
        isapprox(ray1.y, ray2.y; kwargs...) &&
        isapprox(ray1.z, ray2.z; kwargs...) &&
        isapprox(ray1.cx, ray2.cx; kwargs...) &&
        isapprox(ray1.cy, ray2.cy; kwargs...) &&
        isapprox(ray1.cz, ray2.cz; kwargs...)
end


