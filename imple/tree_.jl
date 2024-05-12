using Plots
Plots.default(show=true)
include("../src/mesh.jl")

mutable struct Node{T}
    region::T
    children::Vector{Node{T}}
end

struct QuadTree{T}
    root::Node{T}
end

struct Rectangle
    x::Float64
    y::Float64
    width::Float64
    height::Float64
end

function split(region::Rectangle)
    half_width = region.width / 2
    half_height = region.height / 2

    return [
        Rectangle(region.x, region.y, half_width, half_height),
        Rectangle(region.x + half_width, region.y, half_width, half_height),
        Rectangle(region.x, region.y + half_height, half_width, half_height),
        Rectangle(region.x + half_width, region.y + half_height, half_width, half_height)
    ]
end

function should_subdivide(region::Rectangle, phi::Function)
    # Évaluer phi aux quatre coins de la région
    values = [
        phi(region.x, region.y),
        phi(region.x + region.width, region.y),
        phi(region.x, region.y + region.height),
        phi(region.x + region.width, region.y + region.height)
    ]

    # Vérifier si le signe de phi change
    return any(v > 0 for v in values) && any(v < 0 for v in values)
end

function subdivide(node::Node{T}, level::Int, max_level::Int, should_subdivide::Function, phi::Function) where T
    if level < max_level && should_subdivide(node.region, phi)
        subregions = split(node.region)
        node.children = [Node{T}(subregion, []) for subregion in subregions]
        for child in node.children
            subdivide(child, level + 1, max_level, should_subdivide, phi)
        end
    end
end

function subdivide(tree::QuadTree{T}, max_level::Int, should_subdivide::Function, phi::Function) where T
    subdivide(tree.root, 0, max_level, should_subdivide, phi)
end

function plot_region(region::Rectangle, p::Plots.Subplot{Plots.GRBackend})
    x = region.x
    y = region.y
    width = region.width
    height = region.height

    plot!(p, [x, x + width, x + width, x, x], [y, y, y + height, y + height, y], color = :black, lw = 2, label=false)
end

function plot_tree(node::Node{T}, p::Plots.Subplot{Plots.GRBackend}) where T
    plot_region(node.region, p)
    for child in node.children
        plot_tree(child, p)
    end
    return p
end

function plot_tree(tree::QuadTree{T}, p::Plots.Subplot{Plots.GRBackend}) where T
    plot_tree(tree.root, p)
    return p
end

function search_node(node::Node{T}, target::Rectangle) where T
    if node.region == target
        return node
    else
        for child in node.children
            result = search_node(child, target)
            if result != nothing
                return result
            end
        end
    end
    return nothing
end

function search_node(tree::QuadTree{T}, target::Rectangle) where T
    return search_node(tree.root, target)
end

function cartesian_to_quadtree(mesh::CartesianMesh{N}, max_level::Int, should_subdivide::Function, phi::Function) where N
    # Créer le nœud racine du QuadTree
    root_region = Rectangle(mesh.x0[1], mesh.x0[2], cumsum(mesh.h[1])[end], cumsum(mesh.h[2])[end])
    root = Node{Rectangle}(root_region, [])
    tree = QuadTree{Rectangle}(root)

    # Raffiner le QuadTree
    subdivide(tree, max_level, should_subdivide, phi)

    return tree
end

# Test
nx, ny = 10, 10
hx, hy = ones(nx), ones(ny)
x0, y0 = 0.0, 0.0
mesh = CartesianMesh((hx, hy), (x0, y0))
max_level = 6
φ = (x, y) -> sqrt((x)^2 + (y)^2) - 0.5
tree = cartesian_to_quadtree(mesh, max_level, should_subdivide, φ)
#plot_tree(tree)
# Plot 0-level contour of φ
x = range(0, 1.0, length=100)
y = range(0, 1.0, length=100)
z = [φ(xi, yi) for xi in x, yi in y]

# Plot the contour
#contour!(x, y, z, levels=[0], color=:red, lw=2)
#plot!(legend=false)
#readline()

function nodes(tree::QuadTree{T}) where T
    nodes = Set{Tuple{Float64, Float64}}()
    function _nodes(node::Node{T})
        if isempty(node.children)
            push!(nodes, (node.region.x, node.region.y))
            push!(nodes, (node.region.x + node.region.width, node.region.y))
            push!(nodes, (node.region.x, node.region.y + node.region.height))
            push!(nodes, (node.region.x + node.region.width, node.region.y + node.region.height))
        else
            for child in node.children
                _nodes(child)
            end
        end
    end
    _nodes(tree.root)
    return nodes
end

function centers(tree::QuadTree{T}) where T
    centers = []
    function _centers(node::Node{T})
        if isempty(node.children)  # Si le nœud n'a pas d'enfants
            x = node.region.x + node.region.width / 2
            y = node.region.y + node.region.height / 2
            push!(centers, (x, y))
        else  # Si le nœud a des enfants
            for child in node.children
                _centers(child)
            end
        end
    end
    _centers(tree.root)
    return centers
end

function edges(tree::QuadTree{T}) where T
    x_edges = []
    y_edges = []
    function _edges(node::Node{T})
        if isempty(node.children)
            x = node.region.x + node.region.width / 2
            y = node.region.y + node.region.height / 2
            w = node.region.width / 2
            h = node.region.height / 2
            push!(x_edges, (x - w, y))  # Gauche
            push!(x_edges, (x + w, y))  # Droite
            push!(y_edges, (x, y - h))  # Bas
            push!(y_edges, (x, y + h))  # Haut
        else
            for child in node.children
                _edges(child)
            end
        end
    end
    _edges(tree.root)
    return x_edges, y_edges
end

function faces(tree::QuadTree{T}) where T
    x_faces = []
    y_faces = []
    function _faces(node::Node{T})
        if isempty(node.children)
            x = node.region.x + node.region.width / 2
            y = node.region.y + node.region.height / 2
            w = node.region.width / 2
            h = node.region.height / 2
            push!(x_faces, (x - w, y))  # Gauche
            push!(x_faces, (x + w, y))  # Droite
            push!(y_faces, (x, y - h))  # Bas
            push!(y_faces, (x, y + h))  # Haut
        else
            for child in node.children
                _faces(child)
            end
        end
    end
    _faces(tree.root)
    return x_faces, y_faces
end
unzip(pairs) = [x[1] for x in pairs], [x[2] for x in pairs]

function plot_tree(tree::QuadTree; act_nodes=true, act_centers=true, act_edges=true, act_faces=true)
    p = plot(layout=(1, 3), size=(1450, 500))

    n = nodes(tree)
    c = centers(tree)
    x_edges, y_edges = edges(tree)
    x_faces, y_faces = faces(tree)

    n_x, n_y = unzip(n)
    c_x, c_y = unzip(c)
    x_e_x, x_e_y = unzip(x_edges)
    y_e_x, y_e_y = unzip(y_edges)
    x_f_x, x_f_y = unzip(x_faces)
    y_f_x, y_f_y = unzip(y_faces)


    # Plot the tree in the background for each layout
    plot_tree(tree, p[1])
    plot_tree(tree, p[2])
    plot_tree(tree, p[3])

    if act_nodes
        scatter!(p[1], n_x, n_y, label="Nodes", marker=:square, color=:blue)
    end
    if act_centers
        scatter!(p[1], c_x, c_y, label="Centers", marker=:square, color=:orange)
    end
    if act_edges
        scatter!(p[2], x_e_x, x_e_y, label="X Edges", marker=:rtriangle, color=:blue)
        scatter!(p[2], y_e_x, y_e_y, label="Y Edges", marker=:utriangle, color=:red)
    end
    if act_faces
        scatter!(p[3], x_f_x, x_f_y, label="X Faces", marker=:rtriangle, color=:green)
        scatter!(p[3], y_f_x, y_f_y, label="Y Faces", marker=:utriangle, color=:purple)
    end

    return p
end

# Test
n = nodes(tree)
c =centers(tree)
e= edges(tree)
f= faces(tree)

p = plot_tree(tree, act_nodes=true, act_centers=true, act_edges=true, act_faces=true)
readline()