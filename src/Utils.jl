using DataFrames

function tostring(f::Number)
    return replace(string(f), "." => "")
end

function params2str(rho::Int, nu::Int, zeta::Number, eta::Number)
    if zeta == 0
        zeta = convert(Int, zeta)
    end
    if eta == 0
        eta = convert(Int, eta)
    end
    return "rho$(rho)_nu$(nu)_zeta$(tostring(zeta))_eta$(tostring(eta))"
end

history_df2vec = df -> Tuple.(zip(df.src, df.dst))

function moving_average(df::DataFrame, iter::Int)::DataFrame
    _df = copy(df)
    for _ in 1:iter
        push!(_df, zeros(ncol(_df)))
    end
    newdf = similar(_df, 0)

    for i in 1:nrow(df)
        push!(newdf, mean.(eachcol(_df[i:(i + iter), :])))
    end
    return newdf
end