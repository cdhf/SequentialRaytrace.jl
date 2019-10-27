abstract type AbstractMedium end

struct Sellmeier_1{T} <: AbstractMedium
	k1 :: T
	l1 :: T
	k2 :: T
	l2 :: T
	k3 :: T
	l3 :: T
end

struct Constant_Index{T} <: AbstractMedium
	n :: T
end

const air = Constant_Index(1.0)
const silica = Sellmeier_1(6.96166300e-1, 4.67914800e-3, 4.07942600e-1, 1.35120600e-2, 8.974794e-1, 9.7934e+1)


"""
refractive_index(dispersion::M{T}, wavelength) where {M <: AbstractMedium}

Return the refractive index at a given wavelength in micrometer
"""
function refractive_index(medium::Constant_Index, wavelength)
	medium.n
end

function refractive_index(medium::Sellmeier_1, wavelength)
	lsquared = wavelength^2
	a = medium.k1 * lsquared / (lsquared - medium.l1)
	b = medium.k2 * lsquared / (lsquared - medium.l2)
	c = medium.k3 * lsquared / (lsquared - medium.l3)
	sqrt(a + b + c + 1)
end
