
include("../Twitter.jl")

ds = DataFrame(CSV.File("results/2022-08-22/diffs.csv"))
d = ds[1, :]

_theta = ["γ", "c", "oc", "oo", "nc", "no", "y", "r", "<h>", "g"]
_td = [tgamma, tc, toc, too, tnc, tno, ty, tr, th, tg]
_d = [d.gamma, d.c, d.oc, d.oo, d.nc, d.no, d.y, d.r, d.h, d.g]

pltdata = [
    scatterpolar(;
        r=[_td...; _td[1]], theta=[_theta...; _theta[1]], name="Twitter", marker_color=:red
    )
    scatterpolar(;
        r=[_d...; _d[1]],
        theta=[_theta...; _theta[1]],
        name="Proposed Model (best fit)",
        marker_color=:blue,
    )
]
layout = Layout(;
    template=templates[:simple_white],
    font_family="Times New Roman",
    font_size=20,
    legend=attr(; x=0.5, y=1.05, yanchor="bottom", xanchor="center", orientation="h"),
)
plt = plot(pltdata, layout)

savefig(plt, "proposed_model_polar.png")