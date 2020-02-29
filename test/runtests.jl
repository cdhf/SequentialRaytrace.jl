using SafeTestsets

@safetestset "Dispersion tests" begin include("tests_dispersion.jl") end
@safetestset "Promotion tests" begin include("tests_promotion.jl") end
@safetestset "Raytracing tests" begin include("tests_raytracing.jl") end
@safetestset "LsqFit tests" begin include("tests_lsqfit.jl") end
