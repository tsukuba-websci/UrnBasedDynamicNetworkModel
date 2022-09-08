using PlotlyJS
using DataFrames, CSV

##### parameters #####
inputdir = "results/analyzed_classification"
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

function zoom_in(plt::PlotlyJS.SyncPlot)
    return relayout(plt; template=templates[:simple_white], xaxis_range=[10000, 10250])
end

function main()
    if !isdir(inputdir)
        println("The directory $inputdir does not exist.")
        return nothing
    end

    exec()
end

function exec()
    for target in ["twitter", "aps"]
        plt = plot_class_probability(target)
        savefig(plt, "results/imgs/class_probability--$target.png"; scale=2)

        plt_zoomed = zoom_in(plt)
        savefig(plt_zoomed, "results/imgs/class_probability--$target--zoomed.png"; scale=2)
    end
end

main()