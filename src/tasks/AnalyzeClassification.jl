using DataFrames, CSV, JSONTables
using PlotlyJS
using StatsBase

include("../Models.jl")
include("../Classification.jl")

###### parameters #####
outdir = "results/analyzed_classification"
targets = ["twitter", "aps", "min_r"]
#######################



function main()
    if isdir(outdir)
        res = Base.prompt(
            "The directory $outdir exists. Do you want to overwrite it? [y/N]"; default="n"
        )

        if res != "y"
            println("Aborted.")
            return nothing
        end
    end

    rm(outdir; recursive=true, force=true)
    mkpath(outdir)

    for target in targets
        println("start analyzing $(target)...")
        exec(target)
        println("complete analyzing $(target)!")
    end
end

function on_classify(cs::Vector{Classification})
    return function (c1, c2, c3, c4, c5)
        push!(cs, Classification(c1, c2, c3, c4, c5))
    end
end

function on_weight(cws::Vector{ClassWeight})
    return function (c2, c3, c4, c5)
        push!(cws, ClassWeight(c2, c3, c4, c5))
    end
end

function exec(target::String)
    cs = Classification[]
    cws = ClassWeight[]
    p = ModelParams(
        DataFrame(CSV.File("results/distances/$(target).csv"))[
            1, [:rho, :nu, :zeta, :eta]
        ]...,
    )

    if target == "aps"
        s = "asw"
    else
        s = "wsw"
    end

    env, labels, label_history = run_waves_model(
        p.rho,
        p.nu,
        s,
        p.zeta,
        p.eta;
        on_classify=on_classify(cs),
        on_weight=on_weight(cws),
        steps=20000,
    )

    history_df = DataFrame(;
        step=1:length(env.history), src=first.(env.history), dst=last.(env.history)
    )
    labels_df = DataFrame(; id=1:length(labels), label=labels)
    label_history_df = DataFrame(label_history)

    crs = map(ClassificationRatio, cs)
    crs_df = DataFrame(crs)

    cws_df = DataFrame(cws)

    css = map(ClassSize, cs)
    css_df = DataFrame(css)

    cps = map(tup -> ClassProbability(tup...), zip(css, cws))
    cps_df = DataFrame(cps)

    CSV.write("$outdir/history--$(target).csv", history_df)
    CSV.write("$outdir/labels--$(target).csv", labels_df)
    CSV.write("$outdir/label_history--$(target).csv", label_history_df)
    CSV.write("$outdir/classification_ratio--$(target).csv", crs_df)
    CSV.write("$outdir/class_weight--$(target).csv", cws_df)
    CSV.write("$outdir/class_size--$(target).csv", css_df)
    CSV.write("$outdir/class_probability--$(target).csv", cps_df)

    open("$outdir/classification--$(target).json", "w") do file
        write(file, arraytable(DataFrame(cs)))
    end
end

main()
