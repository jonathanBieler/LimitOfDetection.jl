# LimitOfDetection

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://jonathanBieler.github.io/LimitOfDetection.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jonathanBieler.github.io/LimitOfDetection.jl/dev/)
[![Build Status](https://github.com/jonathanBieler/LimitOfDetection.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/jonathanBieler/LimitOfDetection.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/jonathanBieler/LimitOfDetection.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/jonathanBieler/LimitOfDetection.jl)


### LimitOfDetection

The limit of detection (LoD) is the lowest value of a variable `x` at which an event can 
be detected with a given sensitivity. For example, a smoke detector will trigger at a
concentration of 15,000 particles per cm^3 with 95% probability.

This package uses a probit or logit model from the GLM package to estimate the LoD, given a vector
of the variable considered and the corresponding boolean detection status (true = detected). 
In addition it performes sampling using AdaptiveMCMC to provide error estimates on the LoD, and
a plot recipee is provided to visualize the results.

#### Usage

```julia
# generate artificial data   
x = LinRange(0,1,100)
link = ProbitLink()
f = x -> LimitOfDetection.GLM.linkinv(link, 10*x - 5)
Pcall = f.(x) 
detected = [rand() < P for P in Pcall]

# fit model
model = fit(LoDModel, x, detected; Nsamples = 50_000, sensitivity = 0.95, link = ProbitLink())
    
julia> model
Limit of Detection:
────────────────────────────────────────────────────────────
              MLE      Mean        Std  Lower 90%  Upper 90%
────────────────────────────────────────────────────────────
95%-LoD  0.670671  0.670189  0.0134975   0.648664   0.693332
────────────────────────────────────────────────────────────

julia>using Plots; plot(model)

```