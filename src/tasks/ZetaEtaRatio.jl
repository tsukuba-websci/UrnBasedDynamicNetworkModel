using ProgressMeter
using DataFrames, CSV

println("Threads: $(Threads.nthreads())")

include("../AROB_Models.jl")

outdir = mkpath("results/zeta_eta_ratio/history")

zetas = 0:0.005:1

p = Progress(length(zetas); showspeed=true)
Threads.@threads for zeta in zetas
    env, labels, label_tree = run_waves_model(10, 9, zeta, 0.1; steps=20000)

    zetastr = replace(string(zeta), ("." => "-"))
    rename(DataFrame(env.history), [:1 => :src, :2 => :dst]) |>
    CSV.write("$outdir/$zetastr.csv")

    next!(p)
end
