using PlotlyJS
using DataFrames, DataFramesMeta, CSV
using DynamicNetworkMeasuringTools

include("../Calc.jl")
include("../Utils.jl")
include("../PlotUtils.jl")

outdir = "results/imgs"

##### parameters #####
target_history_length = 20000
######################

mkpath(outdir)

function plot_polar(mvs::Vector{MeasuredValues}, labels::Vector{String}; colored=true)
    _theta = ["γ", "C", "OC", "OO", "NC", "NO", "Y", "R", "<h>", "G"]

    dash = ["solid", "dash"]

    pltdata = AbstractTrace[]
    idx = 1
    for (mv, label) in zip(mvs, labels)
        d = [mv.gamma, mv.c, mv.oc, mv.oo, mv.nc, mv.no, mv.y, mv.r, mv.h, mv.g]
        if colored
            push!(
                pltdata,
                scatterpolar(;
                    r=[d...; d[1]], theta=[_theta...; _theta[1]], name=label, color=:G10
                );
            )
        else
            push!(
                pltdata,
                scatterpolar(;
                    r=[d...; d[1]],
                    theta=[_theta...; _theta[1]],
                    name=label,
                    line=attr(; dash=dash[idx], color=:black),
                );
            )
        end
        idx += 1
    end

    layout = Layout(;
        template=templates[:simple_white],
        font_family="Times New Roman",
        font_size=20,
        legend=attr(; x=0.5, y=1.05, yanchor="bottom", xanchor="center", orientation="h"),
    )
    return plot(pltdata, layout)
end

function export_target_polar(target::String; base::Bool=false, colored=true)
    target_distances = DataFrame(
        CSV.File("results/distances$(base ? "--base" : "")/$target.csv")
    )
    analyzed_models = DataFrame(
        CSV.File("results/analyzed_models$(base ? "--base" : "").csv")
    )

    df = leftjoin(target_distances, analyzed_models; on=[:rho, :nu, :zeta, :eta])
    sort!(df, target)

    best_fit_mv = MeasuredValues(df[1, Not(target)]...)

    target_mv = MeasuredValues(
        DataFrame(CSV.File("results/analyzed_targets/$target.csv"))[1, :]...
    )

    plt = plot_polar([best_fit_mv, target_mv], ["Model (best fit)", "target"]; colored)
    mysavefig(
        plt,
        outdir,
        "/polar--$(target)$(base ? "--base" : "")$(colored ? "" : "--monochrome")",
    )
    return plt
end

function export_best_fit_model_triangle(target::String; base::Bool=false)
    target_distances = DataFrame(
        CSV.File("results/distances$(base ? "--base" : "")/$target.csv")
    )
    sort!(target_distances, target)

    (rho, nu, zeta, eta) = target_distances[1, [:rho, :nu, :zeta, :eta]]
    filepath = "results/generated_histories$(base ? "--base" : "")/$(params2str(rho, nu, zeta, eta))--history.csv"
    history = history_df2vec(DataFrame(CSV.File(filepath)))

    plt = plot_rich_get_richer_triangle(history, length(history) ÷ 100)
    relayout!(
        plt;
        template=templates[:simple_white],
        font_family="Times New Roman",
        font_size=20,
        legend=attr(; x=0.5, y=1.05, yanchor="bottom", xanchor="center", orientation="h"),
    )
    mysavefig(plt, outdir, "triangle--best_fit_model_for_$(target)$(base ? "--base" : "")")
    return plt
end

function export_target_triangle(target::String)
    history = history_df2vec(DataFrame(CSV.File("data/$target.csv")))[1:target_history_length]

    plt = plot_rich_get_richer_triangle(history, length(history) ÷ 100)
    relayout!(
        plt;
        template=templates[:simple_white],
        font_family="Times New Roman",
        font_size=20,
        legend=attr(; x=0.5, y=1.05, yanchor="bottom", xanchor="center", orientation="h"),
    )
    mysavefig(plt, outdir, "triangle--target_$(target)")
    return plt
end

function export_best_fit_model_scatter(target::String; base::Bool=false)
    target_distances = DataFrame(
        CSV.File("results/distances$(base ? "--base" : "")/$target.csv")
    )
    sort!(target_distances, target)

    (rho, nu, zeta, eta) = target_distances[1, [:rho, :nu, :zeta, :eta]]
    filepath = "results/generated_histories$(base ? "--base" : "")/$(params2str(rho, nu, zeta, eta))--history.csv"
    history = history_df2vec(DataFrame(CSV.File(filepath)))

    plt = plot_time_access_scatter(history)
    relayout!(
        plt;
        template=templates[:simple_white],
        font_family="Times New Roman",
        font_size=20,
        legend=attr(; x=0.5, y=1.05, yanchor="bottom", xanchor="center", orientation="h"),
    )
    mysavefig(plt, outdir, "scatter--best_fit_model_for_$(target)$(base ? "--base" : "")")
    return plt
end

function export_target_scatter(target::String)
    history = history_df2vec(DataFrame(CSV.File("data/$target.csv")))[1:target_history_length]

    plt = plot_time_access_scatter(history)
    relayout!(
        plt;
        template=templates[:simple_white],
        font_family="Times New Roman",
        font_size=20,
        legend=attr(; x=0.5, y=1.05, yanchor="bottom", xanchor="center", orientation="h"),
    )
    mysavefig(plt, outdir, "scatter--target_$(target)")
    return plt
end

function export_distances(targets::Vector{String})
    namedict = Dict([
        "aps" => "APS Co-authors Network", "twitter" => "Twitter Mentions Network"
    ])

    pltdata::Vector{GenericTrace} = []
    for target in targets
        proposed = DataFrame(CSV.File("results/distances/$target.csv"))[1, target]
        base = DataFrame(CSV.File("results/distances--base/$target.csv"))[1, target]

        push!(
            pltdata,
            bar(;
                name=namedict[target],
                x=["existing model", "proposed model"],
                y=[base, proposed],
            ),
        )
    end

    layout = Layout(;
        template=templates[:simple_white],
        xaxis_title="",
        yaxis_title="Distance between the empirical",
        yaxis_range=[0, 1.4],
        font_family="Times New Roman",
        font_size=20,
        legend=attr(; x=1, y=1, xanchor="right"),
    )
    plt = plot(pltdata, layout)
    mysavefig(plt, outdir, "distnace")
end

function main()
    exec()
end

function exec()
    # export_target_polar("twitter")
    # export_target_polar("aps")

    # export_target_polar("twitter"; colored=false)
    # export_target_polar("aps"; colored=false)

    # export_target_polar("twitter"; base=true)
    # export_target_polar("aps"; base=true)

    # export_target_polar("twitter"; base=true, colored=false)
    # export_target_polar("aps"; base=true, colored=false)

    # export_best_fit_model_triangle("twitter")
    # export_best_fit_model_triangle("aps")
    # export_best_fit_model_triangle("twitter"; base=true)
    # export_best_fit_model_triangle("aps"; base=true)
    # export_target_triangle("twitter")
    # export_target_triangle("aps")

    # export_best_fit_model_scatter("twitter")
    # export_best_fit_model_scatter("aps")
    # export_best_fit_model_scatter("twitter"; base=true)
    # export_best_fit_model_scatter("aps"; base=true)
    # export_target_scatter("twitter")
    # export_target_scatter("aps")

    export_distances(["aps", "twitter"])
end

main()
