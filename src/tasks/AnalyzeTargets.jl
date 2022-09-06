using DataFrames, CSV
include("../Utils.jl")
include("../Calc.jl")

targets = ["twitter", "aps"]
history_length = 20000
outdir = "results/analyzed_targets"

mkpath(outdir)

for target in targets
    history = history_df2vec(DataFrame(CSV.File("data/$target.csv")))[1:history_length]
    target_mv = MeasuredValues(history)

    CSV.write("$outdir/$target.csv", DataFrame([target_mv]))
end