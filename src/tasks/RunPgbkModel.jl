using DataFrames, CSV
using ProgressMeter
using Dates
using ArgParse

include("../AROB_Models.jl")

function exec()
    outdir = "results/generated_histories--pgbk"

    if isdir(outdir)
        ans = Base.prompt(
            "The generated histories have found. Do you want to overwrite? (y/N)";
            default="N",
        )
        if (ans != "y")
            println("Aborted.")
            return nothing
        end
    end

    rm(outdir; recursive=true, force=true)
    mkpath(outdir)

    rhos = 1:30 |> collect
    nus = 1:30 |> collect
    ss = ("asw", "wsw")
    zeta = 0
    eta = 0

    for s in ss
        mkpath("$outdir/$s")
    end

    p = Progress(length(ss) * length(rhos) * length(nus); showspeed=true)
    Threads.@threads for s in ss
        Threads.@threads for rho in rhos
            Threads.@threads for nu in nus
                rhostr = string(rho)
                nustr = string(nu)
                zetastr = replace(string(zeta), "." => "")
                etastr = replace(string(eta), "." => "")

                filename = "rho$(rhostr)_nu$(nustr)_zeta$(zetastr)_eta$(etastr)"

                if (isfile("$outdir/$s/$filename--history.csv"))
                    next!(p)
                    continue
                end

                env = run_pgbk_model(rho, nu, s; steps=20000)
                history_df = DataFrame(;
                    step=1:length(env.history), src=first.(env.history), dst=last.(env.history)
                )
                env = nothing

                CSV.write("$outdir/$s/$filename--history.csv", history_df)
                history_df = nothing

                next!(p)
            end
        end
    end
end

exec()