
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
    return "rho$(rho)_nu$(nu)_gamma$(tostring(zeta))_eta$(tostring(eta))"
end

history_df2vec = df -> Tuple.(zip(df.src, df.dst))