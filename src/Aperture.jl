"""
Defines a circular aperture with a diameter given in mm.
"""
struct ClearDiameter{T <: Real}
    clear_diameter :: T
    ClearDiameter(ca) = ca < zero(typeof(ca)) ? error("ClearDiameter < 0") : new{typeof(ca)}(ca)
end


function convert_fields(t, x :: ClearDiameter)
    ClearDiameter(convert(t, x.clear_diameter))
end


function is_vignetted(ray, aper :: Nothing) where T
    return(false)
end


function is_vignetted(ray, aper :: ClearDiameter{T}) where T
    ray_height = 2 * sqrt(ray.x^2 + ray.y^2)
    return(ray_height > aper.clear_diameter)
end
