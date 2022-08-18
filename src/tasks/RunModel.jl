using DataFrames, CSV
using ProgressMeter
using Dates

include("../AROB_Models.jl")

rhos = 1:10 |> collect
nus = 1:10 |> collect
gammas = 0.1:0.1:1.0 |> collect
etas = 0.1:0.1:1.0 |> collect

rm("results/$(Dates.today())"; recursive=true)
dir = mkpath("results/$(Dates.today())")

p = Progress(length(gammas) * length(etas) * length(rhos) * length(nus); showspeed=true)
Threads.@threads for rho in rhos
    Threads.@threads for nu in nus
        for gamma in gammas
            for eta in etas
                rhostr = string(rho)
                nustr = string(nu)
                gammastr = replace(string(gamma), "." => "")
                etastr = replace(string(eta), "." => "")

                filename = "rho$(rhostr)_nu$(nustr)_gamma$(gammastr)_eta$(etastr)"

                if (
                    isfile("$dir/$filename--history.csv") &&
                    isfile("$dir/$filename--labels.csv") &&
                    isfile("$dir/$filename--label_history.csv")
                )
                    continue
                end

                env, labels, label_history = run_waves_model(
                    rho, nu, gamma, eta; steps=20000
                )
                history_df = DataFrame(;
                    step=1:length(env.history),
                    src=first.(env.history),
                    dst=last.(env.history),
                )
                labels_df = DataFrame(; id=1:length(labels), label=labels)
                label_history_df = DataFrame(label_history)

                CSV.write("$dir/$filename--history.csv", history_df)
                CSV.write("$dir/$filename--labels.csv", labels_df)
                CSV.write("$dir/$filename--label_history.csv", label_history_df)

                next!(p)
            end
        end
    end
end