using PlotlyJS
using DataFrames, CSV
using JSONTables
using StatsBase
using ProgressMeter

include("../PlotUtils.jl")

##### parameters #####
inputdir = "results/analyzed_classification"
outdir = "results/imgs/classification"
targets = ["twitter", "aps", "min_r"]
######################

colors = Dict(
    "violet" => "#A884A3",
    "blue" => "#66A2BB",
    "green" => "#87C08B",
    "orange" => "#DCA753",
    "red" => "#DF736C",
)

function plot_class_probability(target::String)
    df = DataFrame(CSV.File("$inputdir/class_probability--$(target).csv"))
    pltdata = [
        scatter(; x=1:nrow(df), y=df.c2, mode=:lines, name="class2", line=attr(color=colors["red"]))
        scatter(; x=1:nrow(df), y=df.c3, mode=:lines, name="class3", line=attr(color=colors["green"]))
        scatter(; x=1:nrow(df), y=df.c4, mode=:lines, name="class4", line=attr(color=colors["blue"]))
        scatter(; x=1:nrow(df), y=df.c5, mode=:lines, name="class5", line=attr(color=colors["violet"]))
    ]
    plt = plot(pltdata, Layout(; template=templates[:simple_white], font_family="Times New Roman", yaxis_type=:log))
    return plt
end

function plot_class_weight(target::String)
    df = DataFrame(CSV.File("$inputdir/class_weight--$(target).csv"))

    pltdata = [
        scatter(; x=1:nrow(df), y=df.c2, mode=:lines, name="class2", line=attr(color=colors["red"]))
        scatter(; x=1:nrow(df), y=df.c3, mode=:lines, name="class3", line=attr(color=colors["green"]))
        scatter(; x=1:nrow(df), y=df.c4, mode=:lines, name="class4", line=attr(color=colors["blue"]))
        scatter(; x=1:nrow(df), y=df.c5, mode=:lines, name="class5", line=attr(color=colors["violet"]))
    ]
    plt = plot(pltdata, Layout(; template=templates[:simple_white], font_family="Times New Roman", yaxis_type=:log))
    return plt
end

function plot_class_size(target::String)
    df = DataFrame(CSV.File("$inputdir/class_size--$(target).csv"))

    pltdata = [
        scatter(;
            x=1:nrow(df),
            y=df.c1,
            mode=:lines,
            marker_color=colors["orange"],
            name="class1",
        )
        scatter(;
            x=1:nrow(df),
            y=df.c2,
            mode=:lines,
            marker_color=colors["red"],
            name="class2",
        )
        scatter(;
            x=1:nrow(df),
            y=df.c3,
            mode=:lines,
            marker_color=colors["green"],
            name="class3",
        )
        scatter(;
            x=1:nrow(df),
            y=df.c4,
            mode=:lines,
            marker_color=colors["blue"],
            name="class4",
        )
        scatter(;
            x=1:nrow(df),
            y=df.c5,
            mode=:lines,
            marker_color=colors["violet"],
            name="class5",
        )
    ]
    plt = plot(pltdata, Layout(; template=templates[:simple_white], font_family="Times New Roman", yaxis_type=:log))
    return plt
end

function plot_classification_ratio(target::String)
    df = DataFrame(CSV.File("$inputdir/classification_ratio--$(target).csv"))

    pltdata = [
        scatter(; x=1:nrow(df), y=df.c2, mode=:lines, name="class2", line=attr(color=colors["red"]))
        scatter(; x=1:nrow(df), y=df.c3, mode=:lines, name="class3", line=attr(color=colors["green"]))
        scatter(; x=1:nrow(df), y=df.c4, mode=:lines, name="class4", line=attr(color=colors["blue"]))
        scatter(; x=1:nrow(df), y=df.c5, mode=:lines, name="class5", line=attr(color=colors["violet"]))
    ]
    plt = plot(pltdata, Layout(; template=templates[:simple_white], font_family="Times New Roman", yaxis_type=:log))
    return plt
end

function export_class_transition(target::String)
    outdir = mkpath("results/imgs/classification--$(target)")

    println("Collecting classification data. This may take a while.")
    classification = open("$inputdir/classification--$(target).json") do file
        return DataFrame(jsontable(file))
    end
    println("Complete classification data!")

    history = DataFrame(CSV.File("$inputdir/history--$(target).csv"))

    all = [history.src; history.dst]

    counts = DataFrame(;
        id=first.(Tuple.(collect(countmap(all)))),
        count=last.(Tuple.(collect(countmap(all)))),
    )
    sort!(counts, :count; rev=true)
    filter!(row -> row.count > maximum(counts.count) * 0.5, counts)

    agents = counts[:, :id]

    function _plot(agent::Int, ntop::Int)
        pulse = Int[]
        for row in eachrow(history)
            push!(pulse, agent == row.src || agent == row.dst)
        end

        class_history = Int[]
        sizehint!(class_history, nrow(history))

        for row in eachrow(classification)
            if agent in row.c1
                push!(class_history, 1)
            elseif agent in row.c2
                push!(class_history, 2)
            elseif agent in row.c3
                push!(class_history, 3)
            elseif agent in row.c4
                push!(class_history, 4)
            elseif agent in row.c5
                push!(class_history, 5)
            else
                push!(class_history, 0)
            end
        end

        pushfirst!(class_history, 0)

        pltdata = [
            scatter(;
                x=1:nrow(history), y=pulse, yaxis="y2", opacity=0.5, name="active pulse"
            )
            scatter(; x=1:length(class_history), y=class_history, opacity=1, name="class")
        ]

        plt = plot(
            pltdata,
            Layout(;
                template=templates[:simple_white],
                font_family="Times New Roman",
                yaxis=attr(;
                    overlaying="y2",
                    tickvals=[1, 2, 3, 4, 5],
                    ticktext=["class1", "class2", "class3", "class4", "class5"],
                    range=[1, 5],
                ),
                yaxis2=attr(; side="right", range=[0.5, 0.7], tickvals=[]),
                legend=attr(;
                    x=1, y=1.02, yanchor="bottom", xanchor="right", orientation="h"
                ),
                title_text="agent #$(agent) (the top #$(ntop) active agent)",
            ),
        )

        return plt
    end

    p = Progress(length(agents); desc="exporting $target class transition")
    Threads.@threads for (i, agent) in collect(enumerate(agents))
        plt = _plot(agent, i)
        mysavefig(
            plt, outdir, "classification--$(target)--$(i)"; height=256, width=1024, scale=2
        )
        next!(p)
    end
end

function zoom_in(plt::PlotlyJS.SyncPlot)
    return relayout(
        plt;
        template=templates[:simple_white],
        font_family="Times New Roman",
        xaxis_range=[10000, 10250],
        yaxis_type=:log,
        yaxis_range=[],
    )
end

function main()
    if !isdir(inputdir)
        println("The directory $inputdir does not exist.")
        return nothing
    end

    rm(outdir; recursive=true, force=true)
    mkpath(outdir)

    exec()
end

function exec()
    mkpath("$outdir/class_probability")
    for target in targets
        plt = plot_class_probability(target)
        mysavefig(plt, "$outdir/class_probability", "$target")

        plt_zoomed = zoom_in(plt)
        mysavefig(plt_zoomed, "$outdir/class_probability", "$target--zoomed")
    end

    mkpath("$outdir/class_weight")
    for target in targets
        plt = plot_class_weight(target)
        mysavefig(plt, "$outdir/class_weight", "$target")

        plt_zoomed = zoom_in(plt)
        mysavefig(plt_zoomed, "$outdir/class_weight", "$target--zoomed")
    end

    mkpath("$outdir/class_size")
    for target in targets
        plt = plot_class_size(target)
        mysavefig(plt, "$outdir/class_size", "$target")

        plt_zoomed = zoom_in(plt)
        mysavefig(plt_zoomed, "$outdir/class_size", "$target--zoomed")
    end

    mkpath("$outdir/classification_ratio")
    for target in targets
        plt = plot_classification_ratio(target)
        mysavefig(plt, "$outdir/classification_ratio", "$target")

        plt_zoomed = zoom_in(plt)
        mysavefig(plt_zoomed, "$outdir/classification_ratio", "$target--zoomed")
    end
end

main()
