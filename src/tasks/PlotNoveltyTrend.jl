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

        for index in [:y, :r, :g, :h]
            pltdata = [scatter(data; x=:ratio, y=index)]
            layout = Layout(;
                template=templates[:simple_white],
                font_family="Times New Roman",
                font_size=20,
                # xaxis_type=:log,
                # xaxis_tickformat=".1r",
                xaxis_title="ζ/η",
                yaxis_title=indices2str[index],
            )
            plt = plot(pltdata, layout)
            add_vline!(
                plt, best.zeta ./ best.eta; line_color="red", opacity=0.25, line_width=3
            )
            savefig(plt, "$outdir/$target--$index.png"; scale=2)
        end
    end
end

exec()
