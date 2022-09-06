using PolyaUrnSimulator
using DataFrames, CSV
using Graphs
using StatsBase

struct LabelHistoryRecord
    birthstep::Int
    src::Int
    dst::Int
end

"""
waves of novelties モデル
"""
function run_waves_model(
    rho::Int, nu::Int, gamma::Float64, eta::Float64; steps=200000
)::Tuple{Environment,Vector{Int},Vector{LabelHistoryRecord}}
    function f(N_k::Int, N_not_k::Int, gamma::Real)
        return N_k / (N_k + gamma * N_not_k)
    end

    function g(N_k::Int, N_not_k::Int, gamma::Real)
        return (N_k + gamma * f(N_k, N_not_k, gamma) * N_not_k) / (N_k + gamma * N_not_k)
    end

    last_label = 3
    labels = Int[[1, 1]; ones(Int, nu + 1) .* 2; ones(Int, nu + 1) .* 3]
    label_tree = LabelHistoryRecord[]

    unique_history = Vector{Int}()

    """callerエージェントになったか否かのビット列"""
    became_caller = BitVector()

    function get_caller(env::Environment)::Int
        append!(became_caller, zeros(length(env.rhos) - length(became_caller)))

        # 最初は履歴が無いのでデフォルトのget_callerを使う
        if length(env.history) == 0
            next_caller = PolyaUrnSimulator.get_caller(env)
            became_caller[next_caller] |= 1
            return next_caller
        end

        caller, _ = env.history[end]

        # 壺のサイズが0より大きいエージェントを抽出
        all_agents = collect(1:length(env.buffers))[.!isempty.(env.buffers)]
        all_agents_labels = labels[all_agents]
        all_agents_became_caller = became_caller[all_agents]

        # 1ステップ前のcallerエージェントと同じラベルを持つエージェントを抽出
        k_indices = all_agents_labels .== labels[caller]

        # 今まで一度以上callerになったことのあるエージェントを抽出
        novelty_indices = .!all_agents_became_caller

        C1 = all_agents[.!novelty_indices .* k_indices]
        C2 = all_agents[.!novelty_indices .* .!k_indices]
        C3 = all_agents[novelty_indices .* k_indices]
        C4 = all_agents[novelty_indices .* .!k_indices]

        N_k = sum(k_indices)
        N_not_k = sum(.!k_indices)

        wv = Weights(zeros(length(env.buffers)))
        wv[C1] .= 1
        wv[C2] .= gamma * f(N_k, N_not_k, gamma)
        wv[C3] .= g(N_k, N_not_k, gamma)
        wv[C4] .= eta * g(N_k, N_not_k, gamma)

        next_caller = sample(1:length(env.buffers), wv)
        became_caller[next_caller] |= 1
        return next_caller
    end

    env = Environment(; get_caller)
    init_agents = [
        Agent(rho, nu, ssw_strategy!)
        Agent(rho, nu, ssw_strategy!)
    ]
    init!(env, init_agents)

    for step in 1:steps
        step!(env)

        caller, callee = env.history[end]
        if !(callee in unique_history)
            append!(labels, ones(nu + 1) * (last_label + 1))
            push!(label_tree, LabelHistoryRecord(step, labels[callee], last_label + 1))

            last_label = last_label + 1
        end
        push!(unique_history, caller, callee)
    end

    return env, labels, label_tree
end

function run_normal_model(
    rho::Int, nu::Int; steps=200000
)::Tuple{Environment,Vector{Int},Vector{LabelHistoryRecord}}
    last_label = 3
    labels = Int[[1, 1]; ones(Int, nu + 1) .* 2; ones(Int, nu + 1) .* 3]
    label_tree = LabelHistoryRecord[]

    unique_history = Vector{Int}()

    env = Environment()
    init_agents = [
        Agent(rho, nu, ssw_strategy!)
        Agent(rho, nu, ssw_strategy!)
    ]
    init!(env, init_agents)

    for step in 1:steps
        step!(env)

        caller, callee = env.history[end]
        if !(callee in unique_history)
            append!(labels, ones(nu + 1) * (last_label + 1))
            push!(label_tree, LabelHistoryRecord(step, labels[callee], last_label + 1))

            last_label = last_label + 1
        end
        push!(unique_history, caller, callee)
    end

    return env, labels, label_tree
end