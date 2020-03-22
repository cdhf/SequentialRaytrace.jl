module SequentialRaytrace

import Base: convert, isapprox, promote_rule

include("Dispersion.jl")
export ConstantIndex, Sellmeier_1, air, silica, refractive_index

include("Ray.jl")
export ray_from_NA, Ray

include("Errors.jl")
export error_type

include("Aperture.jl")
export ClearDiameter

include("Surfaces.jl")
export sag

include("Sphere.jl")
export plano, sphere

include("EvenAsphere.jl")
export even_asphere

include("Paraxial.jl")
export paraxial

include("Lens.jl")
export gen_result, make_lens, Object, OpticalComponent
export track_length, trace!

end # module
