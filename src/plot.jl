trim_zeros(x) = begin
    parts = split(x, '.')
    if all(x == '0' for x in parts[2])
        return parts[1]
    end
    x
end

@recipe function f(model::LoDModel; CI_level = 0.9, label = "x")

    # set up the subplots
    legend := false
    markersize := 3
    titlefontsize := 10

    t  = x -> round(x, digits=3) |> string |> trim_zeros
    lod_label = "$(t(100*model.sensitivity))%-LoD"

    q1 = quantile(model, (1-CI_level)/2)
    q2 = quantile(model, 1 - (1-CI_level)/2)
    μ = t(mean(model))
    lod_title = "$lod_label: $(μ)%, $(t(100*CI_level))%-CI: [$(t(q1)), $(t(q2))]"

    layout := @layout [logit           
                       lod{0.5w} params{0.5w}]

    @series begin
        seriestype := :vspan
        subplot := 1
        alpha := 0.5
        color := "lightgray"
        x = [q1, q2]    
    end

    @series begin
        seriestype := :scatter
        subplot := 1
        color := "lightgray"
        x = getfield.(model.data,:x)
        y = getfield.(model.data,:detected)
        x, y
    end

    @series begin
        seriestype := :vline
        subplot := 1
        color := "lightgray"
        
        x = [MLE(model)]
    end
    
    @series begin
        seriestype := :line
        color := :black
        subplot := 1
        xlabel := label
        ylabel := "P(detection)"
        title := lod_title

        x = getfield.(model.data,:x)
        y = predict(model.lm, (;x=x))
        x, y
    end

    @series begin
        seriestype := :histogram
        subplot := 2
        xlabel := lod_label
        ylabel := "Density"
        bins := 100
        normalize := true
        title := "LoD distribution"

        x =  model.lods
        x
    end

    @series begin
        seriestype := :histogram2d
        subplot := 3
        xlabel := "Intercept"
        ylabel := "Slope"
        title := "Parameters distribution"
        bins := 100
        
        x =  model.samples[1,:]
        y =  model.samples[2,:]
        x, y
    end
     
end

