using Plots
Plots.default(show = true)
import Base: -

struct Vertex
    x::Float64
    y::Float64
    Vertex(x, y) = new(x, y)
end
function -(v1::Vertex, v2::Vertex)
    return Vertex(v1.x - v2.x, v1.y - v2.y)
end
function norm(v::Vertex)
    return sqrt(v.x^2 + v.y^2)
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

mutable struct QuadTree
    cells::Vector{Cell}
    vertices::Vector{Vertex}
    edges::Vector{Edge}
    faces::Vector{Face}
    D::Vector{Float64}
    QuadTree(cells, vertices, edges, faces, D) = new(cells, vertices, edges, faces, D)
end

function vertices(cell::Cell)
    return cell.vertices
end

function split!(cell::Cell, tree::QuadTree, φ, max_level)
    if cell.level >= max_level
        return
    end
    vertices = cell.vertices
    center = cell.center
    x1, y1 = vertices[1].x, vertices[1].y
    x2, y2 = vertices[3].x, vertices[3].y
    x3, y3 = (x1 + x2) / 2, (y1 + y2) / 2
    center1 = Vertex((x1 + x3) / 2, (y1 + y3) / 2)
    center2 = Vertex((x3 + x2) / 2, (y1 + y3) / 2)
    center3 = Vertex((x1 + x3) / 2, (y3 + y2) / 2)
    center4 = Vertex((x3 + x2) / 2, (y3 + y2) / 2)
    vertices1 = [Vertex(x1, y1), Vertex(x3, y1), Vertex(x3, y3), Vertex(x1, y3)]
    vertices2 = [Vertex(x3, y1), Vertex(x2, y1), Vertex(x2, y3), Vertex(x3, y3)]
    vertices3 = [Vertex(x1, y3), Vertex(x3, y3), Vertex(x3, y2), Vertex(x1, y2)]
    vertices4 = [Vertex(x3, y3), Vertex(x2, y3), Vertex(x2, y2), Vertex(x3, y2)]
    new_cells = [Cell(vertices1, center1, cell.level + 1), Cell(vertices2, center2, cell.level + 1), Cell(vertices3, center3, cell.level + 1), Cell(vertices4, center4, cell.level + 1)]
    append!(tree.cells, new_cells)
end

function refine_tree!(tree::QuadTree, φ, L, max_splits, max_level)
    new_cells = []
    splits = 0
    for (i, cell) in enumerate(tree.cells)
        min_φ = minimum([abs(φ(v.x, v.y)) for v in vertices(cell)])
        println("Min |φ| in cell ", i, ": ", min_φ)
        if min_φ <= L * sqrt(2) * cell.size && splits < max_splits
            println("Splitting cell ", i)
            split!(cell, tree, φ, max_level)  # Pass φ as the third argument
            append!(new_cells, tree.cells[end-3:end])  # add the new cells to new_cells
            splits += 1
        else
            println("Not splitting cell ", i)
            push!(new_cells, cell)  # keep the old cell
        end
    end
    tree.cells = new_cells  # replace the old cells with the new ones
end

function plot_tree(tree::QuadTree, φ)
    plot() # create a new plot

    # Plot each cell as a separate series
    map(tree.cells) do cell
        # Get the vertices of the cell
        v = cell.vertices
        # Create an array of x and y coordinates
        x = [vertex.x for vertex in v]
        y = [vertex.y for vertex in v]
        # Add the first vertex to the end to close the rectangle
        push!(x, v[1].x)
        push!(y, v[1].y)
        # Plot the rectangle
        plot!(x, y, seriestype=:shape, line=1, fill=false)
    end

    # Create a grid of points
    x = range(-1, stop=1, length=100)
    y = range(-1, stop=1, length=100)
    z = [φ(i, j) for j in y, i in x]

    # Add the 0-level set curve
    contour!(x, y, z, levels=[0], line=2, color=:black)

    display(plot)
end

# Define your computational domain D and level set function φ here
D = [-1, 1, -1, 1]
φ = (x, y) -> sqrt(x^2 + y^2) - 0.5
L = 1.2

# Define the vertices of the root cell
vertice = [Vertex(-1.0, -1.0), Vertex(1.0, -1.0), Vertex(1.0, 1.0), Vertex(-1.0, 1.0)]

# Define the center of the root cell
center = Vertex(0.0, 0.0)

# Create the root cell
root_cell = Cell(vertice, center, 0)

# Create the QuadTree with the root cell
tree = QuadTree([root_cell], Vertex[], Edge[], Face[], [-1.0, 1.0, -1.0, 1.0])

# Refine the QuadTree based on the level set function φ
refine_tree!(tree, φ, L, 500, 5)  # limit to 1000 splits and maximum level 5

@show tree.cells
# Plot the QuadTree
plot_tree(tree, φ)
readline()