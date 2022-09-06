
function tostring(f::Float64)
    return replace(string(f), "." => "")
end

function params2str(rho::Int, nu::Int, zeta::Float64, eta::Float64)
    return "rho$(rho)_nu$(nu)_gamma$(tostring(zeta))_eta$(tostring(eta))"
end

history_df2vec = df -> Tuple.(zip(df.src, df.dst))