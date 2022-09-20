using DataFrames, CSV
using ArgParse

##### parameters #####

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

analyzed_models_file = ""
outdir = ""

function main()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--base"
        help = "Calculate diffs between base model"
        action = :store_true
    end

    args = parse_args(s)
    isbase = args["base"]

    if isbase
        global outdir = "results/distances--base"
        global analyzed_models_file = "results/analyzed_models--base.csv"
    else
        global outdir = "results/distances"
        global analyzed_models_file = "results/analyzed_models.csv"
    end

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

    # Rを最も小さくするパラメータも出す
    analyzed_models = DataFrame(CSV.File("results/analyzed_models.csv"))
    min_r_params = (; sort(analyzed_models, :r)[1, [:rho, :nu, :zeta, :eta]]..., min_r=0)
    CSV.write("$outdir/min_r.csv", DataFrame(; min_r_params...))
end

main()