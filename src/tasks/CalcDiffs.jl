using DynamicNetworkMeasuringTools
using StatsBase
using DataFrames, CSV
using ProgressMeter

# Twitterデータ収集
include("../twitter.jl")

if (!isfile("results/2022-08-28/diffs.csv"))
    # メインデータ
    rhos = 1:10
    nus = 1:10
    zetas = 0.1:0.1:1.0
    etas = 0.1:0.1:1.0

    ds = DataFrame(;
        rho=Int[],
        nu=Int[],
        zeta=Float64[],
        eta=Float64[],
        gamma=Float64[],
        c=Float64[],
        oc=Float64[],
        oo=Float64[],
        nc=Float64[],
        no=Float64[],
        y=Float64[],
        r=Float64[],
        h=Float64[],
        g=Float64[],
        db=Float64[],
        da=Float64[],
        d=Float64[],
    )
    lk = ReentrantLock()
    p = Progress(length(rhos) * length(nus) * length(zetas) * length(etas); showspeed=true)
    Threads.@threads for rho in rhos
        Threads.@threads for nu in nus
            for zeta in zetas
                for eta in etas
                    history_df = DataFrame(
                        CSV.File(
                            "results/2022-08-18/rho$(rho)_nu$(nu)_gamma$(replace(string(zeta), "." => ""))_eta$(replace(string(eta), "." => ""))--history.csv",
                        ),
                    )
                    history = Tuple.(zip(history_df.src, history_df.dst))

                    gamma, _ = calc_gamma(history)
                    c = calc_cluster_coefficient(history)
                    oc, oo, nc, no = calc_connectedness(history) |> values
                    y, _ = calc_youth_coefficient(history, 100)
                    r = calc_recentness(history, length(history) ÷ 100)
                    h = calc_local_entropy(history, length(history) ÷ 100) |> mean
                    g, _ = calc_ginilike_coefficient(history)
                    db, da = calc_jsd(twitter_history, history)

                    d =
                        [
                            gamma - tgamma
                            c - tc
                            oc - toc
                            oo - too
                            nc - tnc
                            no - tno
                            y - ty
                            r - tr
                            h - th
                            g - tg
                            db
                            da
                        ] .|>
                        abs |>
                        sum

                    lock(lk) do
                        push!(
                            ds,
                            [
                                rho
                                nu
                                zeta
                                eta
                                gamma
                                c
                                oc
                                oo
                                nc
                                no
                                y
                                r
                                h
                                g
                                db
                                da
                                d
                            ],
                        )
                    end
                    next!(p)
                end
            end
        end
    end

    mkpath("results/2022-08-22")
    sort!(ds, :d)
    ds |> CSV.write("results/2022-08-22/diffs.csv")
end

ds = DataFrame(CSV.File("results/2022-08-22/diffs.csv"))

mds = ds[1, :]

history_df = DataFrame(
    CSV.File(
        "results/2022-08-18/rho$(mds.rho)_nu$(mds.nu)_gamma$(replace(string(mds.zeta), "." => ""))_eta$(replace(string(mds.eta), "." => ""))--history.csv",
    ),
)
history = history_df |> eachrow .|> (row -> (row.src, row.dst))

_theta = ["γ", "c", "oc", "oo", "nc", "no", "y", "r", "<h>", "g"]
_td = [tgamma, tc, toc, too, tnc, tno, ty, tr, th, tg]
_d = [mds.gamma, mds.c, mds.oc, mds.oo, mds.nc, mds.no, mds.y, mds.r, mds.h, mds.g]
using PlotlyJS

pltdata = [
    scatterpolar(;
        r=[_td...; _td[1]], theta=[_theta...; _theta[1]], name="Twitter", marker_color=:red
    )
    scatterpolar(;
        r=[_d...; _d[1]],
        theta=[_theta...; _theta[1]],
        name="Model (best fit)",
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
savefig(plt, "temp.png"; scale=3, width=512, height=512)

plot_rich_get_richer_triangle(history, 100)
plot_rich_get_richer_triangle(twitter_history, 100)

plot_time_access_scatter(history)
plot_time_access_scatter(twitter_history)

_data = ds[(ds.rho .== mds.rho) .& (ds.nu .== mds.nu), [:zeta, :eta, :d]]
pltdata = heatmap(_data; x=:zeta, y=:eta, z=:d, colorscale="Plotly3")
layout = Layout(;
    template=templates[:simple_white],
    title_text="ρ=$(mds.rho), ν=$(mds.nu), ζ=$(mds.zeta), η=$(mds.eta)",
    title_xanchor="center",
    title_x=0.5,
    xaxis_title="ζ",
    yaxis_title="η",
    yaxis_scaleanchor="x",
    font_family="Times New Roman",
    font_size=20,
)
plt = plot(pltdata, layout)
savefig(plt, "best_fit_zeta_eta.pdf"; width=720, height=720)
savefig(plt, "best_fit_zeta_eta.png"; width=720, height=720)
