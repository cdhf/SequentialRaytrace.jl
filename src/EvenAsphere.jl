struct EvenAsphere{T} <: AbstractSurface{T}
    curvature :: T
    conic :: T
    c4 :: T
    c6 :: T
    c8 :: T
end

function even_asphere(curvature, conic, c4, c6, c8, aperture, n, t)
    OpticalSurface(EvenAsphere(curvature, conic, c4, c6, c8), aperture, n, t, nothing)
end

function even_asphere(curvature, conic, c4, c6, c8, aperture, n, t, id)
    OpticalSurface(EvenAsphere(curvature, conic, c4, c6, c8), aperture, n, t, id)
end

export even_asphere

# Raytrace für gerade Asphären

"""
Even asphere sag
"""
function sag_evenasphere(radial_dist, s)
    z = s.curvature * radial_dist^2 / abs(1 + sqrt(1 - s.curvature^2 * radial_dist^2))
    z = z + s.c4 * radial_dist^4
    z = z + s.c6 * radial_dist^6
    return(z + s.c8 * radial_dist^8)
end

function sag(x, y, s :: EvenAsphere)
    radius = sqrt(x^2 + y^2)
    return(sag_evenasphere(radius, s))
end

"""
modelled after us_itera.c example from Zemax user defined surface DLLs
"""
function transfer_to_intersection_evenasphere(ray :: Ray{T}, s :: EvenAsphere{T}) where T
    t = 100.0
    x = ray.x
    y = ray.y
    z = ray.z
    loop = 0
    while abs(t) > 1e-10
        p2 = sqrt(x^2 + y^2)
        alpha = 1.0 - (1.0 + s.conic) * s.curvature^2 * p2
        if alpha < 0.0
            return RayMissError()
        end
        sag = sag_evenasphere(p2, s)
        dz = sag - z
        t = dz / ray.cz
        x += ray.cx * t
        y += ray.cy * t
        z += ray.cz * t
        loop += 1
        if loop > 1000
            return IntersectionMaxIterationsError(1000)
        end
    end

    Ray(x, y, z, ray.cx, ray.cy, ray.cz)
end

function refract(ray, m0, s :: EvenAsphere, m1, wavelength)
    if m0 == m1
        return ray
    end

    x = ray.x
    y = ray.y
    z = ray.z
    X = ray.cx
    Y = ray.cy
    Z = ray.cz
    k = s.conic
    cv = s.curvature
    r2 = x^2 + y^2
    if r2 == 0
        ln = 0
        mn = 0
        nn = -1
    else
        alpha0 = 1.0 - (1.0 + k)*cv*cv*r2;
        alpha = 1.0 - (1.0 + k) * cv*cv * r2
        if alpha < 0
            return RayMissError()
        end
        alpha = sqrt(alpha)
        mm0 = (cv / (1.0 + alpha))*(2.0 + (cv*cv*r2*(1.0 + k)) / (alpha*(1.0 + alpha)))
        mm = (cv / (1.0+alpha)) * (2.0 + (cv*cv * r2 * (1.0+k)) / (alpha*(1.0+alpha)))
        mm += 4 * s.c4 * r2^(4/2 - 1)
        mm += 6 * s.c6 * r2^(6/2 - 1)
        mm += 8 * s.c8 * r2^(8/2 - 1)

        mm0 += 4.0 * s.c4 * r2;
        mm0 += 6.0 * s.c6 * r2 * r2;
        mm0 += 8.0 * s.c8 * r2 * r2 * r2;

        mx = x * mm
        my = y * mm
        nn = -sqrt(1/(1+mx^2+my^2))
        ln = -mx * nn
        mn = -my * nn

        nn0 = -sqrt(1 / (1 + (mx*mx) + (my*my)))
        ln0 = -mx*nn
        mn0 = -my*nn0
    end
    nr = refractive_index(m0, wavelength) / refractive_index(m1, wavelength)
    cosi = abs(X * ln + Y * mn + Z * nn)
    cosi2 = cosi * cosi
    if cosi2 > 1
        cosi2 = 1
    end
    rad = 1 - ((1 - cosi2) * nr^2)
    if rad < 0
        return TotalInternalReflectionError()
    end
    cosr = sqrt(rad)
    gamma = nr * cosi - cosr
    X = nr * X + gamma * ln
    Y = nr * Y + gamma * mn
    Z = nr * Z + gamma * nn

    Ray(x, y, z, X, Y, Z)
end

function transfer_to_intersection(ray :: Ray{T}, t :: T, s :: EvenAsphere{T}) where T
    # propagiere den Strahl erstmal zur sphärischen Grundfläche,
    # was wahrscheinlich ein ganz guter Startwert ist
    # TODO: missing error handling
    ts = transfer_to_intersection(ray, t, Sphere(s.curvature))
    if iserror(ts)
        return ts
    else
        (ray_at_sphere, _E1) = ts
        return transfer_to_intersection_evenasphere(ray_at_sphere, s)
    end
end
