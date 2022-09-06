using PlotlyJS
using DataFrames, DataFramesMeta, CSV

include("../Calc.jl")

aps_distances = DataFrame(CSV.File("results/distances/aps.csv"))
analyzed_models = DataFrame(CSV.File("results/analyzed_models.csv"))

df = leftjoin(aps_distances, analyzed_models; on=[:rho, :nu, :zeta, :eta])
sort!(df, :aps)

MeasuredValues(df[1, Not(:aps)]...)