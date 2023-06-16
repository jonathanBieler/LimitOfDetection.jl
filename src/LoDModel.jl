struct LoDModel{T} 
    lm::T
    samples::Matrix{Float64}
    lods::Vector{Union{Missing, Float64}}
    MLE_lod::Union{Missing, Float64}
    data::Vector{NamedTuple{(:x, :detected), Tuple{Float64, Bool}}}
    sensitivity::Float64
end

show(io::IO, m::LoDModel) = begin
    println(io, "Limit of Detection:")

    ml = MLE(m)
    lod = mean(m)
    level = 0.90
    qlow  = quantile(m, (1-level)/2)
    qhigh = quantile(m, 1 - (1-level)/2)
    sd = std(m.lods)

    levstr = isinteger(level*100) ? string(Integer(level*100)) : string(level*100)
    sens_str = isinteger(m.sensitivity*100) ? string(Integer(m.sensitivity*100)) : round(m.sensitivity*100, digits=2)
    lod_label = "$(sens_str)%-LoD"

    ct = GLM.StatsBase.CoefTable(hcat(ml, lod, sd, qlow, qhigh),
                      ["MLE", "Mean", "Std", "Lower $levstr%","Upper $levstr%"],
                      [lod_label], 0, 0)

    show(io, ct)
end

function logit_model(p, link)
    α, β = p
    x -> GLM.linkinv(link, α + β*x)
end

function _loglikelihood(p, data, link)
    L = 0.
    P = logit_model(p, link)
    D = x -> Bernoulli(P(x))

    for (x, detected) in data
        L += logpdf(D(x), detected)
    end
    L
end

fit_glm(data, link) = glm(@formula(detected ~ x), data, Binomial(), link)

function sample_posterior(lm, data, link; Nsamples = 10_000)
    p0 = GLM.coef(lm)
    out = adaptive_rwm(p0, p->_loglikelihood(p, data, link), Nsamples; algorithm=:ram)
    samples = out.X
    samples
end

find_lod(p, link, sensitivity, domain) = try 
    P = logit_model(p, link)
    find_zero(x -> P(x) - sensitivity, domain, Bisection())
catch err
    missing
end

function fit(::Type{LoDModel}, x::AbstractVector, detected::AbstractVector{Bool}; 
    Nsamples = 50_000, 
    sensitivity = 0.95,
    link = ProbitLink()
    )
    
    data = [(x = x, detected = detected) for (x, detected) in zip(x, detected)]

    lm = fit_glm(data, link)
    samples = sample_posterior(lm, data, link; Nsamples = Nsamples)

    domain = (minimum(x)-1, maximum(x)+1)

    MLE_lod  = find_lod(GLM.coef(lm), link, sensitivity, domain)
    lods = [find_lod(samples[:,i], link, sensitivity, domain) for i in axes(samples,2)]
    lods = skipmissing(lods) |> collect

    LoDModel{typeof(lm)}(lm, samples, lods, MLE_lod, data, sensitivity)
end

mean(m::LoDModel) = mean(m.lods)
quantile(m::LoDModel, q) = quantile(m.lods, q)
MLE(m::LoDModel) = m.MLE_lod