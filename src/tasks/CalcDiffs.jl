using DataFrames, CSV

##### parameters #####
analyzed_models_file = "results/analyzed_models.csv"
outdir = "results/distances"

######################

include("../Calc.jl")
include("../Utils.jl")

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
    if !isfile(analyzed_models_file)
        println("Cannot find $analyzed_models_file.")
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

    analyzed_target_paths = readdir("results/analyzed_targets")
    targets = map(path -> replace(path, ".csv" => ""), analyzed_target_paths)
    exec(targets)
end

function exec(targets::Vector{String})
    ahs = DataFrame(CSV.File(analyzed_models_file))
    mvs = map(ah -> MeasuredValues(ah...), eachrow(ahs))

    for target in targets
        target_mv = MeasuredValues(
            DataFrame(CSV.File("results/analyzed_targets/$target.csv"))[1, :]...
        )

        distances = Distance[]
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