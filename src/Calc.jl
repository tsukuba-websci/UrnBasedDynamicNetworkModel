using DynamicNetworkMeasuringTools

include("./Models.jl")

struct MeasuredValues
    rho::Int
    nu::Int
    zeta::Float64
    eta::Float64
    gamma::Float64
    c::Float64
    oc::Float64
    oo::Float64
    nc::Float64
    no::Float64
    y::Float64
    r::Float64
    h::Float64
    g::Float64
end

MeasuredValuesDiff = MeasuredValues

function MeasuredValues(
    history::Vector{Tuple{Int,Int}}, mp::ModelParams=ModelParams(0, 0, 0, 0)
)::MeasuredValues
    gamma, _ = calc_gamma(history)
    c = calc_cluster_coefficient(history)
    oc, oo, nc, no = calc_connectedness(history) |> values
    y, _ = calc_youth_coefficient(history, 100)
    r = calc_recentness(history, length(history) ÷ 100)
    h = calc_local_entropy(history, length(history) ÷ 100) |> mean
    g, _ = calc_ginilike_coefficient(history)

    return MeasuredValues(
        mp.rho, mp.nu, mp.zeta, mp.eta, gamma, c, oc, oo, nc, no, y, r, h, g
    )
end

import Base.:-
function Base.:-(a::MeasuredValues, b::MeasuredValues)::MeasuredValuesDiff
    return MeasuredValuesDiff(
        0,
        0,
        0,
        0,
        a.gamma - b.gamma,
        a.c - b.c,
        a.oc - b.oc,
        a.oo - b.oo,
        a.nc - b.nc,
        a.no - b.no,
        a.y - b.y,
        a.r - b.r,
        a.h - b.h,
        a.g - b.g,
    )
end

import Base.abs
function Base.abs(mv::MeasuredValuesDiff)
    return [
        mv.gamma
        mv.c
        mv.oc
        mv.oo
        mv.nc
        mv.no
        mv.y
        mv.r
        mv.h
        mv.g
    ] .|> abs
end