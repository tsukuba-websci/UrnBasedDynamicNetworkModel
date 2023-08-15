using DataFrames, CSV
using ProgressMeter
using ArgParse

include("../Utils.jl")
include("../Models.jl")
include("../Calc.jl")

outfile = ""

function params2str(p::ModelParams)
    return params2str(p.rho, p.nu, p.zeta, p.eta)
end

function main()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--base"
        help = "Analyze base models"
        action = :store_true
    end

    args = parse_args(s)

    if args["base"]
        global outfile = "results/analyzed_models--base.csv"
    else
        global outfile = "results/analyzed_models.csv"
    end

    if isfile(outfile)
        ans = Base.prompt("The file $outfile exists. Do you want to overwrite it? [y/N]")
        if ans != "y"
            println("Aborted.")
            return nothing
        end
    end

    println("Start analyzing. This may take about 10 minutes or more.")
    exec(args["base"])
end

function exec(base::Bool)
    rhos::AbstractRange = 0:0
    nus::AbstractRange = 0:0
    zetas::AbstractRange = 0:0
    etas::AbstractRange = 0:0

    if base
        rhos = 1:20
        nus = 1:20
        zetas = 0:0
        etas = 0:0
    else
        rhos = 1:10
        nus = 1:10
        zetas = 0.1:0.1:1.0
        etas = 0.1:0.1:1.0
    end

    mvs = MeasuredValues[]

    p = Progress(length(rhos) * length(nus) * length(zetas) * length(etas); showspeed=true)
    lk = ReentrantLock()
    Threads.@threads for rho in rhos
        Threads.@threads for nu in nus
            for zeta in zetas
                for eta in etas
                    params = ModelParams(rho, nu, zeta, eta)
                    history_filepath = "results/generated_histories$(base ? "--base" : "" )/$(params2str(params))--history.csv"
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

    mkpath("results")
    CSV.write(outfile, DataFrame(mvs))
end

main()