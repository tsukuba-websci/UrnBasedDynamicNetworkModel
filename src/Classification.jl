struct Classification
    c1::Vector{Int}
    c2::Vector{Int}
    c3::Vector{Int}
    c4::Vector{Int}
    c5::Vector{Int}
end

struct ClassificationRatio
    c1::Float64
    c2::Float64
    c3::Float64
    c4::Float64
    c5::Float64
end

function ClassificationRatio(c::Classification; use_c1::Bool=false)
    lc1 = length(c.c1)
    lc2 = length(c.c2)
    lc3 = length(c.c3)
    lc4 = length(c.c4)
    lc5 = length(c.c5)

    if use_c1
        l = lc1 + lc2 + lc3 + lc4 + lc5
        return ClassificationRatio(lc1 / l, lc2 / l, lc3 / l, lc4 / l, lc5 / l)
    else
        l = lc2 + lc3 + lc4 + lc5
        return ClassificationRatio(0, lc2 / l, lc3 / l, lc4 / l, lc5 / l)
    end
end

struct ClassWeight
    c2::Float64
    c3::Float64
    c4::Float64
    c5::Float64
end

struct ClassSize
    c1::Int
    c2::Int
    c3::Int
    c4::Int
    c5::Int
end

function ClassSize(c::Classification)
    return ClassSize(length(c.c1), length(c.c2), length(c.c3), length(c.c4), length(c.c5))
end

struct ClassProbability
    c1::Float64
    c2::Float64
    c3::Float64
    c4::Float64
    c5::Float64
end

function ClassProbability(cs::ClassSize, cw::ClassWeight)
    sum_weight = sum([
        cs.c1 * 0
        cs.c2 * cw.c2
        cs.c3 * cw.c3
        cs.c4 * cw.c4
        cs.c5 * cw.c5
    ])

    return ClassProbability(
        (0 / sum_weight) * cs.c1,
        (cw.c2 / sum_weight) * cs.c2,
        (cw.c3 / sum_weight) * cs.c3,
        (cw.c4 / sum_weight) * cs.c4,
        (cw.c5 / sum_weight) * cs.c5,
    )
end