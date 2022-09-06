using StatsBase
using DataFrames, CSV
using ArgParse

sample_n = n -> v -> begin
    n = min(length(v), n)
    sample(v, n; replace=false)
end
parseint = s -> parse(Int, s)

function run()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "input_dir"
        required = true
        help = "the path to APS_aff_data_ISI_original directory"
    end

    args = parse_args(s)
    exec(args["input_dir"])
end

function exec(input_dir::String)
    filepaths = readdir(input_dir; join=true)

    papers = Vector{Int}[]

    for filepath in filepaths
        file = open(filepath)
        papers_in_file = readlines(file)
        close(file)

        for paper in papers_in_file
            authors = map(parseint, split(paper, "\t"))
            push!(papers, authors)
        end
    end

    histories = map(sample_n(2), papers)

    CSV.write("data/aps.csv", DataFrame(; src=first.(histories), dst=last.(histories)))
end

run()