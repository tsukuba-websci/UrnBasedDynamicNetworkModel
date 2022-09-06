using DataFrames, CSV
using ProgressMeter

include("../Utils.jl")
include("../AROB_Models.jl")
include("../Calc.jl")

outfile = "results/analyzed_histories.csv"

function params2str(p::ModelParams)
    return params2str(p.rho, p.nu, p.zeta, p.eta)
end

function main()
    if isfile(outfile)
        ans = Base.prompt("The file $outfile exists. Do you want to overwrite it? [y/N]")
        if ans != "y"
            println("Aborted.")
            return nothing
        end
    end

    println("Start analyzing. This may take about 10 minutes or more.")
    exec()
end

function exec()
    rhos = 1:10
    nus = 1:10
    zetas = 0.1:0.1:1.0
    etas = 0.1:0.1:1.0

    mvs = MeasuredValues[]

    p = Progress(length(rhos) * length(nus) * length(zetas) * length(etas); showspeed=true)
    lk = ReentrantLock()
    Threads.@threads for rho in rhos
        Threads.@threads for nu in nus
            for zeta in zetas
                for eta in etas
                    params = ModelParams(rho, nu, zeta, eta)
                    history_filepath = "results/generated_histories/$(params2str(params))--history.csv"
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