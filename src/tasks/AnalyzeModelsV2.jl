using DataFrames, CSV
using ProgressMeter
using ArgParse

include("../Utils.jl")
include("../AROB_Models.jl")
include("../Calc.jl")

function params2str(p::ModelParams)
    return params2str(p.rho, p.nu, p.zeta, p.eta)
end

function main()
    if (length(ARGS) != 1)
        throw(error("ターゲットとするデータを指定してください"))
    end
    target = ARGS[1]

    println("Start analyzing. This may take about 10 minutes or more.")
    exec(target)
end

function exec(target::String)
    rhos = 1:10
    nus = 1:10
    zetas = 0.1:0.1:1.0
    etas = 0.1:0.1:1.0

    mvs = MeasuredValues[]

    p = Progress(length(rhos) * length(nus) * length(zetas) * length(etas); showspeed=true)
    lk = ReentrantLock()
    Threads.@threads for rho in rhos
        Threads.@threads for nu in nus
            Threads.@threads for zeta in zetas
                Threads.@threads for eta in etas
                    try
                        params = ModelParams(rho, nu, zeta, eta)
                        history_filepath = "$(target)/$(params2str(params))--history.csv"
                        df = DataFrame(CSV.File(history_filepath))
                        history = Tuple.(zip(df.src, df.dst))
                        mv = MeasuredValues(history, params)

                        lock(lk) do
                            push!(mvs, mv)
                            next!(p)
                        end
                    catch
                        next!(p)
                    end
                end
            end
        end
    end

    mkpath("results/analyzed/")
    CSV.write("results/analyzed/$(basename(target)).csv", DataFrame(mvs))
end

main()