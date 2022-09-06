using DataFrames, DataFramesMeta, CSV
using PlotlyJS

rho = 10
nu = 6
eta = 0.1

all_diffs = DataFrame(CSV.File("results/2022-08-22/diffs.csv"))

diffs = @subset(all_diffs, :rho .== rho, :nu .== nu, :eta .== eta)
diffs.theta = diffs.zeta ./ diffs.eta
sort!(diffs, :theta)

_data = @select(diffs, :theta, :r, :g, :h, :y)

function _plot(s::Symbol)
    layout = Layout(;
        template=templates[:simple_white],
        font=attr(; family="Times New Roman", size=20),
        xaxis_title="ζ / η",
        yaxis_title="$s",
    )
    plot(_data, layout; x=:theta, y=s)
end

dir = mkpath("imgs/analyzed")
for s in [:r, :g, :h, :y]
    plt = _plot(s)
    savefig(plt, "$dir/zeta_eta_ratio__$(s)__rho7_nu7.png"; scale=3, width=512, height=512)
    savefig(plt, "$dir/zeta_eta_ratio__$(s)__rho7_nu7.pdf"; width=512, height=512)
end