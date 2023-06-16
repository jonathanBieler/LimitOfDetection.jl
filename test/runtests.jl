using LimitOfDetection, Random, Plots
using Test, Statistics

@testset "LimitOfDetection.jl" begin
    
    Random.seed!(0)
    x = LinRange(0,1,1000)
    link = ProbitLink()
    f = x -> LimitOfDetection.GLM.linkinv(link, 10*x - 5)
    Pcall = f.(x) 

    detected = [rand() < P for P in Pcall]
    model = fit(LoDModel, x, detected; Nsamples = 50_000, sensitivity = 0.95, link = ProbitLink())
    
    # make sure it works with BitVectors
    detected = BitVector(detected)
    model = fit(LoDModel, x, detected; Nsamples = 50_000, sensitivity = 0.95, link = ProbitLink())

    lod_theory = LimitOfDetection.find_zero(x->f(x) - 0.95, (0,1))
    @test abs(MLE(model) - lod_theory)/lod_theory < 1/100
    @test (mean(model) - lod_theory)/lod_theory < 5/100 # mean a-posteriori doesn't necessarily match MLE

    x = LinRange(0,1,100)
    f = x -> LimitOfDetection.GLM.linkinv(link, 10*x - 5)
    Pcall = f.(x) 
    detected = [rand() < P for P in Pcall]
    model = fit(LoDModel, x, detected; Nsamples = 50_000, sensitivity = 0.95, link = ProbitLink())

    p = plot(model, size = (600,600), CI_level = 0.95, label = "x")
    #savefig(p, joinpath("docs/", "lod_plot.png"))

end
