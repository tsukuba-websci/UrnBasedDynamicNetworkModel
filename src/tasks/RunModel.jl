using DataFrames, CSV
using ProgressMeter
using Dates
using ArgParse

include("../Models.jl")
include("../Utils.jl")

function main()
    if (length(ARGS) != 1 || !(ARGS[1] == "asw" || ARGS[1] == "wsw"))
        throw(error("Please enter asw or wsw"))
    end
    s = ARGS[1]

    outdir = "results/generated_histories__/$s"
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

    rhos = 2:2:30 |> collect
    nus = 2:2:30 |> collect
    zetas = 0.2:0.2:1.0 |> collect
    etas = 0.2:0.2:1.0 |> collect

    exec(outdir, rhos, nus, s, zetas, etas)
end

function exec(outdir, rhos, nus, s, zetas, etas)

    p = Progress(length(zetas) * length(etas) * length(rhos) * length(nus); showspeed=true)
    Threads.@threads for rho in rhos
        Threads.@threads for nu in nus
            for zeta in zetas
                for eta in etas
                    rhostr = string(rho)
                    nustr = string(nu)
                    zetastr = replace(string(zeta), "." => "")
                    etastr = replace(string(eta), "." => "")

                    filename = "rho$(rhostr)_nu$(nustr)_zeta$(zetastr)_eta$(etastr)"

                    if (
                        isfile("$outdir/$filename--history.csv") &&
                        isfile("$outdir/$filename--labels.csv") &&
                        isfile("$outdir/$filename--label_history.csv")
                    )
                        next!(p)
                        continue
                    end

                    env, labels, label_history = run_waves_model(
                        rho, nu, s, zeta, eta; steps=20000
                    )
                    save_history(env, "$outdir/$filename--history.csv")
                    save_labels(labels, "$outdir/$filename--labels.csv")
                    save_label_history(label_history, "$outdir/$filename--label_history.csv")

                    next!(p)
                end
            end
        end
    end
end

main()