"""
Defines a circular aperture with a diameter given in mm.
"""
struct ClearDiameter{T <: Real}
    clear_diameter :: T
end


function with_fieldtype(t, x :: ClearDiameter)
    ClearDiameter(convert(t, x.clear_diameter))
end


function is_vignetted(ray :: Ray{T}, aper :: Nothing) where T
    return(false)
end


function is_vignetted(ray :: Ray{T}, aper :: ClearDiameter{T}) where T
    ray_height = 2 * sqrt(ray.x^2 + ray.y^2)
    return(ray_height > aper.clear_diameter)
end
