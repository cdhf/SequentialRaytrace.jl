module SequentialRaytrace

import Base: convert, isapprox, promote_rule

include("Dispersion.jl")
export ConstantIndex, Sellmeier_1, Air, Silica, refractive_index

include("Ray.jl")
export ray_from_NA, Ray

include("Errors.jl")
export error_type

include("Aperture.jl")
export ClearDiameter

include("Surfaces.jl")
export sag

include("Sphere.jl")
export Plano, Sphere

include("EvenAsphere.jl")
export EvenAsphere

include("Paraxial.jl")
export Paraxial

include("Lens.jl")
export gen_result, Lens, Object, OpticalComponent
export track_length, trace!

end # module
