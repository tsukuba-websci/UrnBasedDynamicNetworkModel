using DataFrames, CSV

##### parameters #####

history_length = 20000
targets = ["twitter", "aps"]
analyzed_histories_file = "results/analyzed_histories.csv"
outdir = "results/distances"

######################

include("../Calc.jl")

history_df2vec = df -> Tuple.(zip(df.src, df.dst))

struct Distance
    rho::Int
    nu::Int
    zeta::Float64
    eta::Float64
    distance::Float64
end

function Distance(model::MeasuredValues, target::MeasuredValues)
    distance = (model - target) |> abs |> sum
    return Distance(model.rho, model.nu, model.zeta, model.eta, distance)
end

function main()
    if !isfile(analyzed_histories_file)
        println("Cannot find $analyzed_histories_file.")
        return nothing
    end

    if isdir(outdir)
        ans = Base.prompt(
            "The directory $outdir exists. Do you want to overwrite it? [y/N]"; default="N"
        )
        if ans != "y"
            println("Aborted.")
            return nothing
        end
    end

    rm(outdir; force=true, recursive=true)
    mkdir(outdir)

    exec()
end

function exec()
    ahs = DataFrame(CSV.File(analyzed_histories_file))
    mvs = map(ah -> MeasuredValues(ah...), eachrow(ahs))

    for target in targets
        distances = Distance[]
        history = history_df2vec(DataFrame(CSV.File("data/$target.csv")))[1:history_length]
        target_mv = MeasuredValues(history)

        for mv in mvs
            push!(distances, Distance(mv, target_mv))
        end

        distances_df = DataFrame(distances)
        sort!(distances_df, [:distance])
        rename!(distances_df, :distance => target)
        CSV.write("$outdir/$target.csv", distances_df)
    end
end

main()