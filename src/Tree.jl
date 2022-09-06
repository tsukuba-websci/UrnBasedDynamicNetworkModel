using AbstractTrees
using DataFrames, CSV

include("./AROB_Models.jl")

struct LabelTreeNode
    label::Int
    birthstep::Int
    parent::Union{LabelTreeNode,Nothing}
    children::Vector{LabelTreeNode}
end

AbstractTrees.nodevalue(t::LabelTreeNode) = t.label;
AbstractTrees.children(node::LabelTreeNode) = node.children
AbstractTrees.printnode(io::IO, node::LabelTreeNode) = print(io, "#", node.label)
AbstractTrees.parent(node::LabelTreeNode) = node.parent

struct LabelTree
    nodes::Dict{Int,LabelTreeNode}
    root::LabelTreeNode
end

function find_roots(tree_history::Vector{LabelHistoryRecord})::Vector{Int}
    srcs = map(r -> r.src, tree_history)
    dsts = map(r -> r.dst, tree_history)
    return setdiff(srcs, dsts)
end

function LabelTree(label_history::Vector{LabelHistoryRecord}, root_label::Int)
    root = LabelTreeNode(root_label, 1, nothing, [])
    tree = LabelTree(Dict(root_label => root), root)

    for label_history_record in label_history
        src = label_history_record.src
        dst = label_history_record.dst
        birthstep = label_history_record.birthstep

        if (src in keys(tree.nodes) && !(dst in keys(tree.nodes)))
            tree.nodes[dst] = LabelTreeNode(dst, birthstep, tree.nodes[src], [])
            push!(tree.nodes[src].children, tree.nodes[dst])
        end
    end
    return tree
end

function LabelHistoryRecord(row::DataFrameRow)
    return LabelHistoryRecord(row.birthstep, row.src, row.dst)
end

label_history_df = DataFrame(
    CSV.File("results/2022-08-18/rho1_nu1_gamma01_eta01--label_history.csv")
)
label_history = label_history_df |> eachrow .|> LabelHistoryRecord

roots = find_roots(label_history)
tree = LabelTree(label_history, roots[1])

leave = collect(Leaves(tree.root))[101]

root::LabelTreeNode = tree.root
node::LabelTreeNode = leave
i::Int = 0
while (node.parent != root)
    node = node.parent
    i += 1
end
i
