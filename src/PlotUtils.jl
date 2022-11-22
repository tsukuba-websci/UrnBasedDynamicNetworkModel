using PlotlyJS

function mysavefig(plt::PlotlyJS.SyncPlot, outdir::String, name::String; args...)
    savefig(plt, "$outdir/$name.png"; scale=2, args...)
    savefig(plt, "$outdir/$name.pdf", args...)
    println("plot saved ($outdir/$name.png)")
end