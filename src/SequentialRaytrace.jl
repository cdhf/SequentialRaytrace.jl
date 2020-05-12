"""
SequentialRaytrace is a package for sequential ray tracing of
optical systems.
"""
module SequentialRaytrace

include("Dispersion.jl")
export Air, Silica
export ConstantIndex, Sellmeier_1
export refractive_index

include("Ray.jl")
export Ray
export ray_from_NA

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
export Lens, Object, OpticalComponent
export gen_result, track_length, trace!

end # module
