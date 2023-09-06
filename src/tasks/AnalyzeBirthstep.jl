using JSONTables
using DataFrames
using CSV
using ProgressMeter
using PlotlyJS

include("../Utils.jl")

target_dataset = "aps"

classification =
    open("results/analyzed_classification/classification--$(target_dataset).json") do file
        return DataFrame(jsontable(file))
    end

history_df = DataFrame(
    CSV.File("results/analyzed_classification/history--$(target_dataset).csv")
)

struct AgentState
    call::Bool
    called::Bool
    class::String
end

output_dir = "results/triangle/$(target_dataset)"
rm(output_dir; recursive=true, force=true)
mkpath(output_dir)

using DynamicNetworkMeasuringTools
history = history_df2vec(history_df)
tau = div(length(history), 100)
separators = 1:tau:length(history)
intervals = [history[separator:min(separator + tau, end)] for separator in separators]

agent_birthsteps = DynamicNetworkMeasuringTools.get_birthsteps(history)
most_accessed_agents = DataFrame([
    most_accessed_agent_birthstep_in_interval(interval, agent_birthsteps) for
    interval in intervals
])
rename!(most_accessed_agents, :1 => :aid, :2 => :birthstep)

flatten_history = vcat(collect.(history)...)
count_aid = aid -> length(findall(el -> el == aid, flatten_history))

count_aid_df = DataFrame(;
    aid=most_accessed_agents.aid, count=count_aid.(most_accessed_agents.aid)
)

data = leftjoin(count_aid_df, most_accessed_agents; on=:aid)
data.interval = 1:nrow(data)

CSV.write("$output_dir/data.csv", data)

p = Progress(nrow(data); showspeed=true)
Threads.@threads for target_aid in data.aid
    agent_state_history = AgentState[]

    for (index, record) in enumerate(eachrow(history_df))
        call = false
        called = false
        class = "unknown"
        if record.src == target_aid
            call = true
        elseif record.dst == target_aid
            called = true
        end

        if index > 1
            classes = classification[index - 1, :]
            if target_aid in classes.c1
                class = "c1"
            elseif target_aid in classes.c2
                class = "c2"
            elseif target_aid in classes.c3
                class = "c3"
            elseif target_aid in classes.c4
                class = "c4"
            elseif target_aid in classes.c5
                class = "c5"
            end
        end

        push!(agent_state_history, AgentState(call, called, class))
    end

    agent_state_history

    # ash = agent_state_history
    ash_df = DataFrame(agent_state_history)
    ash_df[:, :cumsum] .= cumsum((ash_df.call .+ ash_df.called))

    plot(ash_df.cumsum)

    CSV.write("$output_dir/history_$target_aid.csv", ash_df)
    next!(p)
end