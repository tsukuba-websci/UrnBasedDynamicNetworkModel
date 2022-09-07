using DataFrames, CSV
using ProgressMeter
using Dates
using ArgParse

include("../AROB_Models.jl")

function exec()
    outdir = "results/generated_histories--base"

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

    rhos = 1:20 |> collect
    nus = 1:20 |> collect
    zeta = 0
    eta = 0

    p = Progress(length(rhos) * length(nus); showspeed=true)
    Threads.@threads for rho in rhos
        Threads.@threads for nu in nus
            rhostr = string(rho)
            nustr = string(nu)
            zetastr = replace(string(zeta), "." => "")
            etastr = replace(string(eta), "." => "")

            filename = "rho$(rhostr)_nu$(nustr)_gamma$(zetastr)_eta$(etastr)"

            if (
                isfile("$outdir/$filename--history.csv") &&
                isfile("$outdir/$filename--labels.csv") &&
                isfile("$outdir/$filename--label_history.csv")
            )
                next!(p)
                continue
            end

            env, labels, label_history = run_normal_model(rho, nu; steps=20000)
            history_df = DataFrame(;
                step=1:length(env.history), src=first.(env.history), dst=last.(env.history)
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

exec()