using DataFrames, CSV
using ProgressMeter

include("../Calc.jl")

eta = 0.1
zetas = 0:0.005:1

mvs = MeasuredValues[]
p = Progress(length(zetas); showspeed=true)
Threads.@threads for zeta in zetas
    zeta_str = replace(string(zeta), "." => "-")
    df = DataFrame(CSV.File("results/zeta_eta_ratio/history/$zeta_str.csv"))
    history = Tuple.(eachrow(df))
    mv = MeasuredValues(history, ModelParams(20, 1, zeta, eta))
    push!(mvs, mv)
    next!(p)
end

DataFrame(mvs) |> CSV.write("results/zeta_eta_ratio/analyzed.csv")