using DataFrames, DataFramesMeta, CSV
using DynamicNetworkMeasuringTools
using PlotlyJS

include("../AROB_Models.jl")

env, labels, label_tree = run_normal_model(6, 12; steps=20000)

env.history

plt = plot_rich_get_richer_triangle(env.history, length(env.history) ÷ 100)
savefig(plt, "normal_model_triangle.png"; width=500, height=500, scale=2)

labels

history_df = DataFrame(;
    step=1:length(env.history), src=first.(env.history), dst=last.(env.history)
)

history_df.label_src = labels[history_df.src]
history_df.label_dst = labels[history_df.dst]

CSV.write("normal_model_label_history.csv", history_df)

history = env.history

include("../Twitter.jl")

gamma, _ = calc_gamma(history)
c = calc_cluster_coefficient(history)
oc, oo, nc, no = calc_connectedness(history) |> values
y, _ = calc_youth_coefficient(history, 100)
r = calc_recentness(history, length(history) ÷ 100)
h = calc_local_entropy(history, length(history) ÷ 100) |> mean
g, _ = calc_ginilike_coefficient(history)
db, da = calc_jsd(twitter_history, history)

_theta = ["γ", "c", "oc", "oo", "nc", "no", "y", "r", "<h>", "g"]
_td = [tgamma, tc, toc, too, tnc, tno, ty, tr, th, tg]
_d = [gamma, c, oc, oo, nc, no, y, r, h, g]

pltdata = [
    scatterpolar(;
        r=[_td...; _td[1]], theta=[_theta...; _theta[1]], name="Twitter", marker_color=:red
    )
    scatterpolar(;
        r=[_d...; _d[1]],
        theta=[_theta...; _theta[1]],
        name="Agent Based Model (best fit)",
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

savefig(plt, "normal_model_polar.png")