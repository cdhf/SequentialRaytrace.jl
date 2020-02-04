struct Clear_Diameter{T <: Real}
    clear_diameter :: T
end

export Clear_Diameter

function is_vignetted(ray :: Ray{T}, aper :: Nothing) where T
    return(false)
end

function is_vignetted(ray :: Ray{T}, aper :: Clear_Diameter{T}) where T
    ray_height = 2 * sqrt(ray.x^2 + ray.y^2)
    return(ray_height > aper.clear_diameter)
end
