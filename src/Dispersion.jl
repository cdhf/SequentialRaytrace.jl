abstract type AbstractMedium{T <: Real} end


"""
    refractive_index(medium :: AbstractMedium{T}, λ :: T) where T

Return the refractive index of medium at the given wavelength in μm.
"""
function refractive_index end


"""
Definition of a medium with no dispersion.
"""
struct Constant_Index{T} <: AbstractMedium{T}
    n :: T
end


function Base.convert(::Type{Constant_Index{T}}, x :: Constant_Index{R}) where T where R
    Constant_Index{T}(convert(T, x.n))
end


function with_fieldtype(t, x :: Constant_Index)
    convert(Constant_Index{t}, x)
end


function refractive_index(medium :: Constant_Index{T}, λ :: T) where T
    medium.n
end


"""
Definition of a material's dispersion using the Sellmeier equation. This definition is
equivalent to the Zemax Sellmeier_1 dispersion equation.
"""
struct Sellmeier_1{T} <: AbstractMedium{T}
    k1 :: T
    l1 :: T
    k2 :: T
    l2 :: T
    k3 :: T
    l3 :: T
end


function Base.convert(::Type{Sellmeier_1{T}}, x :: Sellmeier_1{R}) where T where R
    Sellmeier_1{T}(
        convert(T, x.k1),
        convert(T, x.l1),
        convert(T, x.k2),
        convert(T, x.l2),
        convert(T, x.k3),
        convert(T, x.l3),
        )
end

function with_fieldtype(t, x :: Sellmeier_1)
    convert(Sellmeier_1{t}, x)
end

function refractive_index(medium :: Sellmeier_1{T}, λ :: T) where T
    λ2 = λ^2
    a = medium.k1 * λ2 / (λ2 - medium.l1)
    b = medium.k2 * λ2 / (λ2 - medium.l2)
    c = medium.k3 * λ2 / (λ2 - medium.l3)
    sqrt(a + b + c + 1)
end


#
# Definition of a few materials
#


"""
Silica dispersion. Coefficients as in Zemax.
"""
const silica = Sellmeier_1(6.96166300e-1, 4.67914800e-3, 4.07942600e-1, 1.35120600e-2, 8.974794e-1, 9.7934e+1)


"""
The refractive index of air is defined to be 1.0 at all wavelengths. This follows the usual
convention to use refractive indices which are relative to air.
"""
const air = Constant_Index(1.0)
