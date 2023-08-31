using DataFrames, CSV
using ProgressMeter
using Dates
using ArgParse

include("../Models.jl")

function main()
    main_dir = "results/generated_histories_10times/"

    for i in range(1, 10)
        outdir = "$main_dir/$i"
        mkpath(outdir)
        exec(outdir)
    end
end

function exec(outdir::String)

    rhos = [1, 5, 10, 15, 20, 25, 30]
    nus = [1, 5, 10, 15, 20, 25, 30]
    zetas = [0.2, 0.4, 0.6, 0.8, 1.0]
    etas = [0.2, 0.4, 0.6, 0.8, 1.0]
    ss = ["asw", "wsw"]

    p = Progress(length(zetas) * length(etas) * length(rhos) * length(nus) * length(ss); showspeed=true)
    Threads.@threads for rho in rhos
        Threads.@threads for nu in nus
            Threads.@threads for s in ss
                for zeta in zetas
                    for eta in etas
                        rhostr = string(rho)
                        nustr = string(nu)
                        zetastr = replace(string(zeta), "." => "")
                        etastr = replace(string(eta), "." => "")

                        filename = "rho$(rhostr)_nu$(nustr)_$(s)_zeta$(zetastr)_eta$(etastr)"

                        if isfile("$outdir/$filename--history.csv")
                            next!(p)
                            continue
                        end

                        env, labels, label_history = run_waves_model(
                            rho, nu, s, zeta, eta; steps=20000
                        )
                        history_df = DataFrame(;
                            step=1:length(env.history),
                            src=first.(env.history),
                            dst=last.(env.history),
                        )

                        env = nothing
                        labels = nothing
                        label_history = nothing

                        CSV.write("$outdir/$filename--history.csv", history_df)

                        history_df = nothing

                        next!(p)
                    end
                end
            end
        end
    end
end

main()