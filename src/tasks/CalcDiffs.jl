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

infile = ""
outdir = ""

function main()

    arg_parse = ArgParseSettings()

    @add_arg_table arg_parse begin
        "model"
        help = "Specify the model (base, pgbk, proposed)"
    end

    args = parse_args(arg_parse)

    if args["model"] == nothing
        model = "proposed"
    else
        model = args["model"]
    end

    if model != "proposed" && model != "base" && model != "pgbk"
        println("Error: Invalid model specified. Please specify base, pgbk, or proposed.")
        return nothing
    end

    if model == "proposed"
        global infile = "analyzed_models.csv"
        global outdir = "results/distances"
    elseif model == "base"
        global infile = "analyzed_models--base.csv"
        global outdir = "results/distances--base"
    elseif model == "pgbk"
        global infile = "analyzed_models--pgbk.csv"
        global outdir = "results/distances--pgbk"
    end

    if isdir(outdir)
        ans = Base.prompt("The directory $outdir exists. Do you want to overwrite it? [y/N]"; default="N")
        if ans != "y"
            println("Aborted.")
            return nothing
        end
    end

    rm(outdir; force=true, recursive=true)
    mkdir(outdir)

    analyzed_target_paths = readdir("results/analyzed_targets")
    targets = map(path -> replace(path, ".csv" => ""), analyzed_target_paths)

    for target in targets
        if target == "aps"
            s = "asw"
        else
            s = "wsw"
        end

        if !isfile("results/$s/$infile")
            println("Cannot find results/$s/$infile.")
            return nothing
        end

        exec(model, target, s)
    end
end


function exec(model::String, target::String, s::String)
    ahs = DataFrame(CSV.File("results/$s/$infile"))
    mvs = map(ah -> MeasuredValues(ah...), eachrow(ahs))

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

    # Rを最も小さくするパラメータも出す
    if model == "proposed"
        analyzed_models = DataFrame(CSV.File("results/$s/$infile"))
        min_r_params = (; sort(analyzed_models, :r)[1, [:rho, :nu, :zeta, :eta]]..., min_r=0)
        CSV.write("$outdir/min_$infile.csv", DataFrame(; min_r_params...))
    end
end

main()
