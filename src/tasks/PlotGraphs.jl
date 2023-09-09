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

colors = Dict(
    "violet" => "#A884A3",
    "blue" => "#66A2BB",
    "green" => "#87C08B",
    "orange" => "#DCA753",
    "red" => "#DF736C",
    "black" => "#555555",
)

mkpath(outdir)


"""
    get_birthsteps(history::History)::Dict{Int, Int}

history中に存在するエージェントの誕生ステップをDictで返す
"""
function get_birthsteps(history::History)::Dict{Int,Int}
    src = history .|> first
    dst = history .|> last
    t = 1:length(src) |> collect
    df = DataFrame(; t, src, dst)

    dfsrc = rename(select(unique(df, :src), [:t, :src]), :src => :aid)
    dfdst = rename(select(unique(df, :dst), [:t, :dst]), :dst => :aid)

    replacemissing! = df -> begin
        for col in eachcol(df)
            replace!(col, missing => length(history) + 1)
        end
        return df
    end
    joined = outerjoin(dfsrc, dfdst; on=:aid, renamecols="_s" => "_d") |> replacemissing!
    joined.t = min.(joined.t_s, joined.t_d)

    return Pair.(joined.aid, joined.t) |> Dict
end

function plot_time_access_scatter(history::History)
    flatten_history = vcat((history .|> collect)...)

    birthsteps = get_birthsteps(history) |> sort |> values |> collect
    counts = countmap(flatten_history) |> sort |> values |> collect

    pltdata = scatter(; x=birthsteps, y=counts ./ length(history), mode="markers", marker=attr(size=7, opacity=0.3))
    layout = Layout(;
        template=templates[:simple_white],
        xaxis=attr(; type=:log, title="Birth step"),
        yaxis=attr(; type=:log, title="Active frequency"),
    )
    return plot(pltdata, layout)
end




function plot_polar(mvs::Vector{MeasuredValues}, labels::Vector{String}, marker_colors::Vector{String}, line_dashes::Vector{String}; colored=true)
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
                    r=[d...; d[1]], theta=[_theta...; _theta[1]], name=label, marker_color=marker_colors[idx], line_dash=line_dashes[idx]
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

function export_target_polar(target::String; colored=true)
    model_dict = Dict([
        "base" => "--base", "pgbk" => "--pgbk", "proposed" => ""
    ])

    if target == "aps"
        s = "asw"
    else
        s = "wsw"
    end

    best_fit_mv = []

    for model in ["base", "pgbk", "proposed"]
        target_distances = DataFrame(CSV.File("results/distances$(model_dict[model])/$target.csv"))
        analyzed_models = DataFrame(CSV.File("results/analyzed_models/$s$(model_dict[model]).csv"))
    df = leftjoin(target_distances, analyzed_models; on=[:rho, :nu, :zeta, :eta])
    sort!(df, target)
        push!(best_fit_mv, MeasuredValues(df[1, Not(target)]...))
    end

    target_mv = MeasuredValues(
        DataFrame(CSV.File("results/analyzed_targets/$target.csv"))[1, :]...
    )

    plt = plot_polar(
        [best_fit_mv[1], best_fit_mv[2], best_fit_mv[3], target_mv],
        ["Ubaldi et al. Model", "Suda et al. Model", "Proposed Model", "Target"],
        [colors["blue"], colors["green"], colors["red"], colors["black"]],
        ["solid", "solid", "solid", "dash"];
        colored
    )
    relayout!(
        plt;
        template=templates[:simple_white],
        font_family="Times New Roman",
        font_size=20,
        legend=attr(; x=0.5, y=1.05, yanchor="bottom", xanchor="center", orientation="h"),
    )
    mysavefig(
        plt,
        outdir,
        "/polar--$(target)$(colored ? "" : "--monochrome")",
    )
    return plt
end

function export_best_fit_model_triangle(target::String; model::String="proposed")
    if model == "proposed"
        option = ""
    elseif model == "base"
        option = "--base"
    elseif model == "pgbk"
        option = "--pgbk"
    else
        println("model = base, proposed or pgbk")
        return
    end
    target_distances = DataFrame(
        CSV.File("results/distances$option/$target.csv")
    )
    sort!(target_distances, target)

    if target == "aps"
        s = "asw"
    else
        s = "wsw"
    end
    (rho, nu, zeta, eta) = target_distances[1, [:rho, :nu, :zeta, :eta]]
    filepath = "results/generated_histories$option/$s/$(params2str(rho, nu, zeta, eta))--history.csv"
    history = history_df2vec(DataFrame(CSV.File(filepath)))

    plt = plot_rich_get_richer_triangle(history, length(history) ÷ 100)
    relayout!(
        plt;
        template=templates[:simple_white],
        font_family="Times New Roman",
        font_size=20,
        legend=attr(; x=0.5, y=1.05, yanchor="bottom", xanchor="center", orientation="h"),
    )
    if !isdir("$outdir/triangle")
        mkdir("$outdir/triangle")
    end
    mysavefig(plt, "$outdir/triangle", "best_fit_model_for_$(target)$option")
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
    if !isdir("$outdir/triangle")
        mkdir("$outdir/triangle")
    end
    mysavefig(plt, "$outdir/triangle", "target_$(target)")
    return plt
end

function export_best_fit_model_scatter(target::String; model::String="proposed")
    if model == "proposed"
        option = ""
    elseif model == "base"
        option = "--base"
    elseif model == "pgbk"
        option = "--pgbk"
    else
        println("model = base, proposed or pgbk")
        return
    end
    target_distances = DataFrame(
        CSV.File("results/distances$option/$target.csv")
    )
    sort!(target_distances, target)

    if target == "aps"
        s = "asw"
    else
        s = "wsw"
    end
    (rho, nu, zeta, eta) = target_distances[1, [:rho, :nu, :zeta, :eta]]
    filepath = "results/generated_histories$option/$s/$(params2str(rho, nu, zeta, eta))--history.csv"
    history = history_df2vec(DataFrame(CSV.File(filepath)))

    plt = plot_time_access_scatter(history)
    relayout!(
        plt;
        template=templates[:simple_white],
        font_family="Times New Roman",
        font_size=20,
        legend=attr(; x=0.5, y=1.05, yanchor="bottom", xanchor="center", orientation="h"),
        yaxis_range=[log(0.012), log(0.5)],
    )
    if !isdir("$outdir/scatter")
        mkdir("$outdir/scatter")
    end
    mysavefig(plt, "$outdir/scatter", "best_fit_model_for_$(target)$option")
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
        yaxis_range=[log(0.012), log(0.5)],
    )
    if !isdir("$outdir/scatter")
        mkdir("$outdir/scatter")
    end
    mysavefig(plt, "$outdir/scatter", "target_$(target)")
    return plt
end

function export_distances(targets::Vector{String})
    namedict = Dict([
        "aps" => "APS Co-authors Network", "twitter" => "Twitter Mentions Network"
    ])

    targets = ["aps", "twitter"]

    x_values = []
    y_values_base = []
    y_values_proposed = []
    y_values_pgbk = []

    for target in targets
        push!(x_values, namedict[target])
        push!(y_values_base, DataFrame(CSV.File("results/distances--base/$target.csv"))[1, target])
        push!(y_values_proposed, DataFrame(CSV.File("results/distances/$target.csv"))[1, target])
        push!(y_values_pgbk, DataFrame(CSV.File("results/distances--pgbk/$target.csv"))[1, target])
    end

    trace_base = bar(
        x=x_values,
        y=y_values_base,
        name="existing model",
        marker_color=colors["blue"],
        showlegend=false
    )

    trace_proposed = bar(
        x=x_values,
        y=y_values_proposed,
        name="proposed model",
        marker_color=colors["red"],
        showlegend=false
    )

    trace_pgbk = bar(
        x=x_values,
        y=y_values_pgbk,
        name="pgbk model",
        marker_color=colors["green"],
        showlegend=false
    )

    pltdata = [trace_base, trace_pgbk, trace_proposed]

    layout = Layout(;
        template=templates[:simple_white],
        xaxis_title="",
        yaxis_title="Distance between the empirical",
        font_family="Times New Roman",
        font_size=20,
        # legend=attr(; x=0, y=1, xanchor="top"),
        legend=attr(visible=false),
    )
    plt = plot(pltdata, layout)
    mysavefig(plt, outdir, "distnace")
end

function main()
    exec()
end

function exec()
    export_target_polar("twitter")
    export_target_polar("aps")


    export_best_fit_model_triangle("twitter")
    export_best_fit_model_triangle("aps")
    export_best_fit_model_triangle("twitter"; model="base")
    export_best_fit_model_triangle("aps"; model="base")
    export_best_fit_model_triangle("twitter"; model="pgbk")
    export_best_fit_model_triangle("aps"; model="pgbk")
    export_target_triangle("twitter")
    export_target_triangle("aps")

    export_best_fit_model_scatter("twitter")
    export_best_fit_model_scatter("aps")
    export_best_fit_model_scatter("twitter"; model="base")
    export_best_fit_model_scatter("aps"; model="base")
    export_best_fit_model_scatter("twitter"; model="pgbk")
    export_best_fit_model_scatter("aps"; model="pgbk")
    export_target_scatter("twitter")
    export_target_scatter("aps")

    export_distances(["aps", "twitter"])
end

main()
