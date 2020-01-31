abstract type AbstractAperture end

struct Unlimited <: AbstractAperture end

struct Clear_Diameter{T <: Real} <: AbstractAperture
    clear_diameter :: T
end

function is_vignetted(ray :: Ray{T}, aper :: Unlimited) where T
    return(false)
end

function is_vignetted(ray :: Ray{T}, aper :: Clear_Diameter) where T
    ray_height = 2 * sqrt(ray.x^2 + ray.y^2)
    return(ray_height > aper.clear_diameter)
end
