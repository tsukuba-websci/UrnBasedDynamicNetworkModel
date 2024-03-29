using DataFrames, CSV
using ProgressMeter
using Dates
using ArgParse

include("../Models.jl")
include("../Utils.jl")

function main()
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

    exec(outdir)
end

function exec(outdir)
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
                filename = params2str(rho, nu, zeta, eta)

                if (isfile("$outdir/$s/$filename--history.csv"))
                    next!(p)
                    continue
                end

                env = run_pgbk_model(rho, nu, s; steps=20000)
                save_history(env, "$outdir/$s/$filename--history.csv")

                next!(p)
            end
        end
    end
end

main()