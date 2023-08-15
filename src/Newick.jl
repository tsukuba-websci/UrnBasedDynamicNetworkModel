using AbstractTrees

include("./Models.jl")
include("./Tree.jl")

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
