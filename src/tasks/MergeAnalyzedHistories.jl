using CSV, DataFrames
using StatsBase

include("../Calc.jl")

ss = ["asw", "wsw"]

files = []
for s in ss
    push!(files, readdir("results/analyzed_models_10times/$s"; join=true))
end
print(files)

dfs = map(file -> DataFrame(CSV.File(file)), files)

gd = groupby(vcat(dfs...), [:rho, :nu, :zeta, :eta])

mean_df = combine(gd, valuecols(gd) .=> mean; renamecols=false)

CSV.write(
    "results/analyzed_models_10times/mean.csv", mean_df
)
