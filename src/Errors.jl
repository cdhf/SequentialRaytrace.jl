"""
This is the parent type for all basic errors during ray tracing.
The type field describes the type of error.
If the maximum number of iterations to find a surface intersection
was too large, n_iterations contains the number of iterations.
"""
struct RayError
    type :: Symbol
    n_iterations :: Integer
end


function ray_miss_error()
    RayError(:ray_miss, 0)
end


function total_internal_reflection_error()
    RayError(:total_internal_reflection, 0)
end


function intersection_max_iterations_error()
    RayError(:intersection_max_iterations, 0)
end


function vignetted_error()
    RayError(:vignetted, 0)
end


iserror(x :: RayError) = true
iserror(x) = false

export iserror


"""
This is the type returned from a ray trace when an error occured
error_type is the actual RayError with any additional specific information
surface_index is the index of the surface that the error occured at
data is the ray trace result up to this point
"""
struct RaytraceError{D} <: Exception
    error_type :: RayError
    surface_index :: Integer # index
    data :: D
end

function iserror(x :: RaytraceError)
    true
end

error_type(err :: RaytraceError) = err.error_type.type
