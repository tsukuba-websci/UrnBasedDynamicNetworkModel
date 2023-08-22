using DataFrames, CSV
using ProgressMeter
using ArgParse

include("../Utils.jl")
include("../Models.jl")
include("../Calc.jl")

indir = ""
outfile = ""

function params2str(p::ModelParams)
    return params2str(p.rho, p.nu, p.zeta, p.eta)
end

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
        global indir = "results/generated_histories"
        global outfile = "analyzed_models.csv"
    elseif model == "base"
        global indir = "results/generated_histories--base"
        global outfile = "analyzed_models--base.csv"
    elseif model == "pgbk"
        global indir = "results/generated_histories--pgbk"
        global outfile = "analyzed_models--pgbk.csv"
    end

    if isfile(outfile)
        ans = Base.prompt("The file $outfile exists. Do you want to overwrite it? [y/N]")
        if ans != "y"
            println("Aborted.")
            return nothing
        end
    end

    println("Start analyzing $model models...")
    exec(model)
end

function exec(model::String)
    rhos::AbstractRange = 0:0
    nus::AbstractRange = 0:0
    zetas::AbstractRange = 0:0
    etas::AbstractRange = 0:0

    ss = ("asw","wsw")
    if model == "proposed"
        rhos = 2:2:30
        nus = 2:2:30
        zetas = 0.2:0.2:1.0
        etas = 0.2:0.2:1.0
    else
        rhos = 1:30
        nus = 1:30
        zetas = 0:0
        etas = 0:0
    end

    mvs = MeasuredValues[]

    p = Progress(length(ss) * length(rhos) * length(nus) * length(zetas) * length(etas); showspeed=true)
    lk = ReentrantLock()
    for s in ss
        Threads.@threads for rho in rhos
            Threads.@threads for nu in nus
                Threads.@threads for zeta in zetas
                    Threads.@threads for eta in etas
                        params = ModelParams(rho, nu, zeta, eta)
                        history_filepath = "$indir/$s/$(params2str(params))--history.csv"
                        df = DataFrame(CSV.File(history_filepath))
                        history = Tuple.(zip(df.src, df.dst))
                        mv = MeasuredValues(history, params)

                        lock(lk) do
                            push!(mvs, mv)
                            next!(p)
                        end
                    end
                end
            end
        end
        mkpath("results/$s")
        CSV.write("results/$s/$outfile", DataFrame(mvs))
    end
end

main()