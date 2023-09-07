using DataFrames, CSV
using ProgressMeter
using ArgParse

include("../Utils.jl")
include("../Models.jl")
include("../Calc.jl")

indir = "results/generated_histories_10times"
outfile = ""

function params2str(p::ModelParams)
    return params2str(p.rho, p.nu, p.zeta, p.eta)
end

function main()
    exec()
end

function exec()
    rhos = [1, 5, 10, 15, 20, 25, 30]
    nus = [1, 5, 10, 15, 20, 25, 30]
    zetas = [0.2, 0.4, 0.6, 0.8, 1.0]
    etas = [0.2, 0.4, 0.6, 0.8, 1.0]
    ss = ["asw", "wsw"]

    for i = 1:10
        for s in ss
            mvs = MeasuredValues[]
            print("$(i) $(s)\n")
            p = Progress(length(rhos) * length(nus) * length(zetas) * length(etas); showspeed=true)
            lk = ReentrantLock()
            Threads.@threads for rho in rhos
                Threads.@threads for nu in nus
                    Threads.@threads for zeta in zetas
                        Threads.@threads for eta in etas
                            params = ModelParams(rho, nu, zeta, eta)
                            history_filepath = "$indir/$i/rho$(rho)_nu$(nu)_$(s)_zeta$(tostring(zeta))_eta$(tostring(eta))--history.csv"
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
            mkpath("results/analyzed_models_10times/$s")
            CSV.write("results/analyzed_models_10times/$s/$(i).csv", DataFrame(mvs))
        end
    end
end

main()