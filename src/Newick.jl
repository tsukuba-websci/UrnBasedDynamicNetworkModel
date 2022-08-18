using AbstractTrees

include("./AROB_Models.jl")

struct LabelTreeNode
    label::Int
    birthstep::Int
    parent::Union{LabelTreeNode,Nothing}
    children::Vector{LabelTreeNode}
end

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

function newick(root::LabelTreeNode)
    d = 0
    if (AbstractTrees.parent(root) !== nothing)
        d = root.birthstep - AbstractTrees.parent(root).birthstep
    end

    if (isempty(root.children))
        return "$(root.label):$d"
    end

    children = join(map(newick, root.children), ",")
    return "($children)$(root.label):$d"
end
