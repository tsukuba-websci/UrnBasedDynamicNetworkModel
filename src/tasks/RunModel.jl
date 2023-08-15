using DataFrames, CSV
using ProgressMeter
using Dates
using ArgParse

include("../Models.jl")

function main()
    if (length(ARGS) != 1 || !(ARGS[1] == "asw" || ARGS[1] == "wsw"))
        throw(error("Please enter asw or wsw"))
    end
    s = ARGS[1]
    exec(s)
end

function exec(s)
    outdir = "results/generated_histories/$s"

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
                    history_df = DataFrame(;
                        step=1:length(env.history),
                        src=first.(env.history),
                        dst=last.(env.history),
                    )
                    labels_df = DataFrame(; id=1:length(labels), label=labels)
                    label_history_df = DataFrame(label_history)

                    env = nothing
                    labels = nothing
                    label_history = nothing

                    CSV.write("$outdir/$filename--history.csv", history_df)
                    CSV.write("$outdir/$filename--labels.csv", labels_df)
                    CSV.write("$outdir/$filename--label_history.csv", label_history_df)

                    history_df = nothing
                    labels_df = nothing
                    label_history_df = nothing

                    next!(p)
                end
            end
        end
    end
end

main()