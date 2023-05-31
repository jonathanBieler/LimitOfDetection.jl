module LimitOfDetection

    using AdaptiveMCMC, GLM, RecipesBase, Roots, Statistics
    using GLM.Distributions
    
    import Base.show
    import StatsBase.fit
    import Statistics.mean, Statistics.quantile

    export ProbitLink, LogitLink, fit, LoDModel, mean, quantile, MLE

    include("LoDModel.jl")
    include("plot.jl")

end
