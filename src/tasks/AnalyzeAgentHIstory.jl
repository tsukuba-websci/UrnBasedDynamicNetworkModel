using JSONTables
using DataFrames
using CSV
using ProgressMeter
using PlotlyJS

include("../Utils.jl")

target_dataset = "twitter"

classification =
    open("results/analyzed_classification/classification--$(target_dataset).json") do file
        return DataFrame(jsontable(file))
    end

history_df = DataFrame(
    CSV.File("results/analyzed_classification/history--$(target_dataset).csv")
)

agents = Int[]
for (src, dst) in eachrow(history_df[:, [:src, :dst]])
    append!(agents, [src, dst])
end
agents = sort(unique(agents))

struct AgentState
    call::Bool
    called::Bool
    class::String
end

output_dir = "results/agent_history/$(target_dataset)"
rm(output_dir; recursive=true, force=true)
mkpath(output_dir)

p = Progress(length(agents); showspeed=true)
Threads.@threads for target_aid in agents
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

    # ash = agent_state_history
    ash_df = DataFrame(agent_state_history)
    ash_df[:, :cumsum] .= cumsum((ash_df.call .+ ash_df.called))

    plot(ash_df.cumsum)

    CSV.write("$output_dir/history_$target_aid.csv", ash_df)
    next!(p)
end