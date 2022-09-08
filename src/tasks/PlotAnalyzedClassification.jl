using PlotlyJS
using DataFrames, CSV

##### parameters #####
inputdir = "results/analyzed_classification"
targets = ["twitter", "aps"]
######################

function plot_class_probability(target::String)
    df = DataFrame(CSV.File("$inputdir/class_probability--$(target).csv"))
    pltdata = [
        scatter(; x=1:nrow(df), y=df.c2, mode=:lines, name="class2")
        scatter(; x=1:nrow(df), y=df.c3, mode=:lines, name="class3")
        scatter(; x=1:nrow(df), y=df.c4, mode=:lines, name="class4")
        scatter(; x=1:nrow(df), y=df.c5, mode=:lines, name="class5")
    ]
    plt = plot(pltdata, Layout(; template=templates[:simple_white], yaxis_range=[0, 1]))
    return plt
end

function plot_class_weight(target::String)
    df = DataFrame(CSV.File("$inputdir/class_weight--$(target).csv"))

    pltdata = [
        scatter(; x=1:nrow(df), y=df.c2, mode=:lines, name="class2")
        scatter(; x=1:nrow(df), y=df.c3, mode=:lines, name="class3")
        scatter(; x=1:nrow(df), y=df.c4, mode=:lines, name="class4")
        scatter(; x=1:nrow(df), y=df.c5, mode=:lines, name="class5")
    ]
    plt = plot(pltdata, Layout(; template=templates[:simple_white], yaxis_type=:log))
    return plt
end

function plot_class_size(target::String)
    df = DataFrame(CSV.File("$inputdir/class_size--$(target).csv"))

    pltdata = [
        scatter(; x=1:nrow(df), y=df.c2, mode=:lines, name="class2")
        scatter(; x=1:nrow(df), y=df.c3, mode=:lines, name="class3")
        scatter(; x=1:nrow(df), y=df.c4, mode=:lines, name="class4")
        scatter(; x=1:nrow(df), y=df.c5, mode=:lines, name="class5")
    ]
    plt = plot(pltdata, Layout(; template=templates[:simple_white], yaxis_type=:log))
    return plt
end

function plot_classification_ratio(target::String)
    df = DataFrame(CSV.File("$inputdir/classification_ratio--$(target).csv"))

    pltdata = [
        scatter(; x=1:nrow(df), y=df.c2, mode=:lines, name="class2")
        scatter(; x=1:nrow(df), y=df.c3, mode=:lines, name="class3")
        scatter(; x=1:nrow(df), y=df.c4, mode=:lines, name="class4")
        scatter(; x=1:nrow(df), y=df.c5, mode=:lines, name="class5")
    ]
    plt = plot(pltdata, Layout(; template=templates[:simple_white], yaxis_type=:log))
    return plt
end

function zoom_in(plt::PlotlyJS.SyncPlot)
    return relayout(
        plt;
        template=templates[:simple_white],
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

    exec()
end

function exec()
    for target in targets
        plt = plot_class_probability(target)
        savefig(plt, "results/imgs/class_probability--$target.png"; scale=2)

        plt_zoomed = zoom_in(plt)
        savefig(plt_zoomed, "results/imgs/class_probability--$target--zoomed.png"; scale=2)
    end

    for target in targets
        plt = plot_class_weight(target)
        savefig(plt, "results/imgs/class_weight--$target.png"; scale=2)

        plt_zoomed = zoom_in(plt)
        savefig(plt_zoomed, "results/imgs/class_weight--$target--zoomed.png"; scale=2)
    end

    for target in targets
        plt = plot_class_size(target)
        savefig(plt, "results/imgs/class_size--$target.png"; scale=2)

        plt_zoomed = zoom_in(plt)
        savefig(plt_zoomed, "results/imgs/class_size--$target--zoomed.png"; scale=2)
    end

    for target in targets
        plt = plot_classification_ratio(target)
        savefig(plt, "results/imgs/classification_ratio--$target.png"; scale=2)

        plt_zoomed = zoom_in(plt)
        savefig(
            plt_zoomed, "results/imgs/classification_ratio--$target--zoomed.png"; scale=2
        )
    end
end

main()
