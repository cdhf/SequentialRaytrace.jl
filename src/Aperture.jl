"""
Defines a circular aperture with a diameter given in mm.
"""
struct Clear_Diameter{T <: Real}
    clear_diameter :: T
end


function with_fieldtype(t, x :: Clear_Diameter)
    Clear_Diameter(convert(t, x.clear_diameter))
end


function is_vignetted(ray :: Ray{T}, aper :: Nothing) where T
    return(false)
end


function is_vignetted(ray :: Ray{T}, aper :: Clear_Diameter{T}) where T
    ray_height = 2 * sqrt(ray.x^2 + ray.y^2)
    return(ray_height > aper.clear_diameter)
end
