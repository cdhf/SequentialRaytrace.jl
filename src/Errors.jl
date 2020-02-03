# import ResultTypes: Result, ErrorResult, iserror, unwrap, unwrap_error

"""
This is the parent type for all basic errors during ray tracing.
"""
abstract type AbstractRayError <: Exception end

struct RayMissError <: AbstractRayError end

struct TotalInternalReflectionError <: AbstractRayError end

struct IntersectionMaxIterationsError <: AbstractRayError
    n_iterations :: Int64
end

struct VignettedError <: AbstractRayError end

export RayMissError, InternalReflectionError, IntersectionMaxIterationsError

function iserror(x :: AbstractRayError)
    true
end

function iserror(x)
    false
end

export iserror


"""
This is the type returned from a ray trace when an error occured
"""
struct RaytraceError{E <: AbstractRayError} <: Exception
    error_type :: E
    data
end

function iserror(x :: RaytraceError)
    true
end
