using DataFrames, DataFramesMeta, CSV
using PlotlyJS

##### parameters #####
outdir = "results/imgs/novelty_trends"
targets = ["twitter", "aps"]
indices2str = Dict(:y => "Y", :r => "R", :g => "G", :h => "<h>")
######################

function exec()
    rm(outdir; force=true, recursive=true)
    mkpath(outdir)
    main()
end

function main()
    namedict = Dict(
        [
            "twitter" => "Twitter Mentions Network"
            "aps" => "APS Co-authors Network"
        ]
    )

    for index in [:y, :r, :g, :h]
        pltdata::Vector{GenericTrace} = []
        for target in targets
            best = NamedTuple(DataFrame(CSV.File("results/distances/$target.csv"))[1, :])
            analyzed = DataFrame(CSV.File("results/analyzed_models.csv"))

            data = @chain analyzed begin
                @rsubset :rho .== best.rho
                @rsubset :nu .== best.nu
                @rsubset :zeta .== best.zeta
                @select :rho :nu :zeta :eta :y :r :h :g
                @orderby -:eta
            end
            best = (; best..., (@rsubset data :eta .== best.eta)[1, [:y, :r, :h, :g]]...)
            data.ratio .= data.zeta ./ data.eta
            push!(pltdata, scatter(data; x=:ratio, y=index, name=namedict[target]))
        end

        layout = Layout(;
            template=templates[:simple_white],
            font_family="Times New Roman",
            font_size=20,
            # xaxis_type=:log,
            # xaxis_tickformat=".1r",
            xaxis_title="ζ/η",
            yaxis_title=indices2str[index],
            legend=attr(; x=1, y=1.02, yanchor="bottom", xanchor="right", orientation="h"),
        )
        plt = plot(pltdata, layout)

        for (target, color) in zip(targets, ["blue", "orange"])
            best = NamedTuple(
                DataFrame(CSV.File("results/analyzed_targets/$target.csv"))[1, :]
            )
            add_hline!(
                plt, getproperty(best, index); line_color=color, opacity=0.25, line_width=3
            )
        end
        savefig(plt, "$outdir/$index.png"; scale=2)
    end
end

exec()
