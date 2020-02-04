# import ResultTypes: Result, ErrorResult, iserror, unwrap, unwrap_error

"""
This is the parent type for all basic errors during ray tracing.
"""

struct RayError
    type :: Symbol
    n_iterations :: Int64
end

function rayMissError()
    RayError(:ray_miss, 0)
end

function totalInternalReflectionError()
    RayError(:total_internal_reflection, 0)
end

function intersectionMaxIterationsError()
    RayError(:intersection_max_iterations, 0)
end

function vignettedError()
    RayError(:vignetted, 0)
end

function iserror(x :: RayError)
    true
end

function iserror(x)
    false
end

export iserror


"""
This is the type returned from a ray trace when an error occured
"""
struct RaytraceError{D} <: Exception
    error_type :: RayError
    data :: D
end

function iserror(x :: RaytraceError)
    true
end

error_type(err :: RaytraceError) = err.error_type.type

export error_type
