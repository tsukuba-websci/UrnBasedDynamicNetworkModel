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

function save_history(env, outfile::String)
    history_df = DataFrame(;
        step=1:length(env.history),
        src=first.(env.history),
        dst=last.(env.history),
    )
    env = nothing
    CSV.write(outfile, history_df)
    history_df = nothing
end

function save_labels(labels, outfile::String)
    labels_df = DataFrame(; id=1:length(labels), label=labels)
    labels = nothing
    CSV.write(outfile, labels_df)
    labels_df = nothing
end

function save_label_history(label_history, outfile::String)
    label_history_df = DataFrame(label_history)
    label_history = nothing
    CSV.write(outfile, label_history_df)
    label_history_df = nothing
end