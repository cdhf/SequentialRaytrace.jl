module SequentialRaytrace

import Base: convert, isapprox, promote_rule

include("Dispersion.jl")
export Constant_Index, Sellmeier_1, air, silica, refractive_index

include("Ray.jl")
export make_ray, ray_from_NA

include("Errors.jl")
export error_type

include("Aperture.jl")
export Clear_Diameter

include("Surfaces.jl")
export sag

include("Sphere.jl")
export sphere, plano

include("EvenAsphere.jl")
export even_asphere

include("Paraxial.jl")
export paraxial

include("Lens.jl")

end # module
