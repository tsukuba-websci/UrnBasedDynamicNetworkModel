using PlotlyJS

Nl = 10
Nnl = 1000

function f(zeta::Real)
    return Nl / (Nl + zeta * Nnl)
end

function cls1(zeta::Real)
    return zeta * f(zeta)
end

x = collect(0:0.01:1.0)
plt = plot(
    x,
    cls1.(x),
    Layout(;
        template=templates[:simple_white],
        xaxis_title="ζ",
        yaxis_title="ζf",
        title="Nl=10, Nnl=1000",
    ),
)
savefig(plt, "temp.png")