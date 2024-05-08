using Plots
Plots.default(show = true)
import Base: -

struct Vertex
    x::Float64
    y::Float64
    z::Float64
    Vertex(x, y, z) = new(x, y, z)
end

function -(v1::Vertex, v2::Vertex)
    return Vertex(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
end

function norm(v::Vertex)
    return sqrt(v.x^2 + v.y^2 + v.z^2)
end

mutable struct Cell
    vertices::Vector{Vertex}
    size::Float64
    center::Vertex
    level::Int
    Cell(vertices, center, level) = new(vertices, norm(vertices[1] - vertices[2]), center, level)
end

struct Edge
    vertices::Vector{Vertex}
    Edge(vertices) = new(vertices)
end

struct Face
    vertices::Vector{Vertex}
    Face(vertices) = new(vertices)
end

mutable struct OctTree
    cells::Vector{Cell}
    vertices::Vector{Vertex}
    edges::Vector{Edge}
    faces::Vector{Face}
    D::Vector{Float64}
    OctTree(cells, vertices, edges, faces, D) = new(cells, vertices, edges, faces, D)
end

function vertices(cell::Cell)
    return cell.vertices
end

function split!(cell::Cell, tree::OctTree, φ, max_level)
    if cell.level >= max_level
        return
    end
    vertices = cell.vertices
    center = cell.center
    x1, y1, z1 = vertices[1].x, vertices[1].y, vertices[1].z
    x2, y2, z2 = vertices[7].x, vertices[7].y, vertices[7].z
    x3, y3, z3 = (x1 + x2) / 2, (y1 + y2) / 2, (z1 + z2) / 2
    new_cells = [
        Cell([Vertex(x1, y1, z1), Vertex(x3, y1, z1), Vertex(x3, y3, z1), Vertex(x1, y3, z1), Vertex(x1, y1, z3), Vertex(x3, y1, z3), Vertex(x3, y3, z3), Vertex(x1, y3, z3)], Vertex((x1 + x3) / 2, (y1 + y3) / 2, (z1 + z3) / 2), cell.level + 1),
        Cell([Vertex(x3, y1, z1), Vertex(x2, y1, z1), Vertex(x2, y3, z1), Vertex(x3, y3, z1), Vertex(x3, y1, z3), Vertex(x2, y1, z3), Vertex(x2, y3, z3), Vertex(x3, y3, z3)], Vertex((x3 + x2) / 2, (y1 + y3) / 2, (z1 + z3) / 2), cell.level + 1),
        Cell([Vertex(x1, y3, z1), Vertex(x3, y3, z1), Vertex(x3, y2, z1), Vertex(x1, y2, z1), Vertex(x1, y3, z3), Vertex(x3, y3, z3), Vertex(x3, y2, z3), Vertex(x1, y2, z3)], Vertex((x1 + x3) / 2, (y3 + y2) / 2, (z1 + z3) / 2), cell.level + 1),
        Cell([Vertex(x3, y3, z1), Vertex(x2, y3, z1), Vertex(x2, y2, z1), Vertex(x3, y2, z1), Vertex(x3, y3, z3), Vertex(x2, y3, z3), Vertex(x2, y2, z3), Vertex(x3, y2, z3)], Vertex((x3 + x2) / 2, (y3 + y2) / 2, (z1 + z3) / 2), cell.level + 1),
        Cell([Vertex(x1, y1, z3), Vertex(x3, y1, z3), Vertex(x3, y3, z3), Vertex(x1, y3, z3), Vertex(x1, y1, z2), Vertex(x3, y1, z2), Vertex(x3, y3, z2), Vertex(x1, y3, z2)], Vertex((x1 + x3) / 2, (y1 + y3) / 2, (z3 + z2) / 2), cell.level + 1),
        Cell([Vertex(x3, y1, z3), Vertex(x2, y1, z3), Vertex(x2, y3, z3), Vertex(x3, y3, z3), Vertex(x3, y1, z2), Vertex(x2, y1, z2), Vertex(x2, y3, z2), Vertex(x3, y3, z2)], Vertex((x3 + x2) / 2, (y1 + y3) / 2, (z3 + z2) / 2), cell.level + 1),
        Cell([Vertex(x1, y3, z3), Vertex(x3, y3, z3), Vertex(x3, y2, z3), Vertex(x1, y2, z3), Vertex(x1, y3, z2), Vertex(x3, y3, z2), Vertex(x3, y2, z2), Vertex(x1, y2, z2)], Vertex((x1 + x3) / 2, (y3 + y2) / 2, (z3 + z2) / 2), cell.level + 1),
        Cell([Vertex(x3, y3, z3), Vertex(x2, y3, z3), Vertex(x2, y2, z3), Vertex(x3, y2, z3), Vertex(x3, y3, z2), Vertex(x2, y3, z2), Vertex(x2, y2, z2), Vertex(x3, y2, z2)], Vertex((x3 + x2) / 2, (y3 + y2) / 2, (z3 + z2) / 2), cell.level + 1)
    ]
    append!(tree.cells, new_cells)
end

function refine_tree!(tree::OctTree, φ, L, max_splits, max_level)
    new_cells = []
    splits = 0
    for (i, cell) in enumerate(tree.cells)
        min_φ = minimum([abs(φ(v.x, v.y, v.z)) for v in cell.vertices])
        println("Min |φ| in cell ", i, ": ", min_φ)
        if min_φ <= L * sqrt(3) * cell.size && splits < max_splits
            println("Splitting cell ", i)
            split!(cell, tree, φ, max_level)  # Pass φ as the third argument
            append!(new_cells, tree.cells[end-7:end])  # add the new cells to new_cells
            splits += 1
        else
            println("Not splitting cell ", i)
            push!(new_cells, cell)  # keep the old cell
        end
    end
    tree.cells = new_cells  # replace the old cells with the new ones
end

using Plots
plotlyjs()

function plot_octree(tree::OctTree, φ)
    p = plot()  # create a new plot
    for cell in tree.cells
        # get the x, y, z coordinates of the vertices
        xs = [v.x for v in cell.vertices]
        ys = [v.y for v in cell.vertices]
        zs = [v.z for v in cell.vertices]
        # plot a cube with these vertices
        plot!(p, xs, ys, zs, seriestype=:shape, alpha=0.5)
    end

    # Plot the 0-level set function φ
    x = range(tree.D[1], tree.D[2], length=100)
    y = range(tree.D[3], tree.D[4], length=100)
    z = range(tree.D[5], tree.D[6], length=100)
    contour!(p, x, y, (x, y) -> φ(x, y, 0), levels=[0], color=:black, linewidth=2)

    display(p)
end

# Define your computational domain D and level set function φ here
D = [-1, 1, -1, 1, -1, 1]
φ(x, y, z) = x^2 + y^2 + z^2 - 0.5
L = 1.2

# Create the initial cell
vertice = [
    Vertex(-1, -1, -1), Vertex(1, -1, -1), Vertex(1, 1, -1), Vertex(-1, 1, -1),
    Vertex(-1, -1, 1), Vertex(1, -1, 1), Vertex(1, 1, 1), Vertex(-1, 1, 1)
]
cell = Cell(vertice, Vertex(0, 0, 0), 0)

# Create the initial tree
tree = OctTree([cell], vertice, [], [], D)

# Refine the tree
refine_tree!(tree, φ, L, 3, 3)

# Plot the tree
plot_octree(tree, φ)
readline()