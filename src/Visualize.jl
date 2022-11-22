using PlotlyJS
using DataFrames, CSV, DataFramesMeta

include("./Twitter.jl")
include("./PlotUtils.jl")

rho = 5
nu = 5
zeta = 0.1
eta = 0.1

function plot_polar(
    rho::Int, nu::Int, zeta::Float64, eta::Float64, filename::Union{String,Nothing}=nothing
)
    ds = @chain DataFrame(CSV.File("results/2022-08-22/diffs.csv")) begin
        @rsubset :rho == rho
        @rsubset :nu == nu
        @rsubset :zeta == zeta
        @rsubset :eta == eta
    end
    d = ds[1, :]

    _theta = ["γ", "c", "oc", "oo", "nc", "no", "y", "r", "<h>", "g"]
    _td = [tgamma, tc, toc, too, tnc, tno, ty, tr, th, tg]
    _d = [d.gamma, d.c, d.oc, d.oo, d.nc, d.no, d.y, d.r, d.h, d.g]

    pltdata = [
        scatterpolar(;
            r=[_td...; _td[1]],
            theta=[_theta...; _theta[1]],
            name="Twitter",
            marker_color=:red,
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

    if filename !== nothing
        mkpath("imgs/analyzed")
        mysavefig(plt, "imgs/analyzed/", filename; width=512, height=512)
    end
    return plt
end

plot_polar(10, 6, 0.7, 0.5)

plot_time_access_scatter