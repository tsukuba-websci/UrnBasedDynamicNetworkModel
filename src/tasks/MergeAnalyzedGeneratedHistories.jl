using CSV, DataFrames
using StatsBase

include("../Calc.jl")

files = readdir("results/analyzed_models_10times"; join=true)

dfs = map(file -> DataFrame(CSV.File(file)), files)

gd = groupby(vcat(dfs...), [:rho, :nu, :zeta, :eta])

CSV.write(
    "results/analyzed_models_10times/mean.csv", combine(gd, valuecols(gd) .=> mean; renamecols=false)
)
