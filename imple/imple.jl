using Plots
Plots.default(show = true)

# Cas 1D
struct Cell
    x1::Float64
    x2::Float64
end

struct Mesh1D
    cells::Array{Cell}
end

function create_mesh(nx::Int, x::Array{Float64})
    cells = Array{Cell}(undef, nx)
    for i in 1:nx
        cell = Cell(x[i], x[i+1])
        cells[i] = cell
    end
    return Mesh1D(cells)
end

function get_cell_points(mesh::Mesh1D, i::Int)
    cell = mesh.cells[i]
    x_points = (cell.x1 + cell.x2) / 2
    return x_points
end

function get_face_points(mesh::Mesh1D, i::Int, direction::Symbol)
    cell = mesh.cells[i]
    if direction == :x
        x_points = (cell.x1 + cell.x2) / 2
    end
    return x_points
end

function plot_mesh(mesh::Mesh1D)
    plot() # Initialise le tracé
    for i in 1:size(mesh.cells, 1)
        cell = mesh.cells[i]
        # Tracer les lignes de la grille
        plot!([cell.x1, cell.x2], [0.5, 0.5], color=:black, legend=false, title="1D Mesh")
        # Tracer les centres des cellules
        scatter!([(cell.x1 + cell.x2) / 2], [0.5], color=:red, markersize=2)
        # Tracer les nœuds de la grille
        scatter!([cell.x1, cell.x2], [0.5, 0.5], color=:blue, markersize=2)
    end
    display(plot)
end

# Cas 2D
struct Cell2D
    x1::Float64
    x2::Float64
    y1::Float64
    y2::Float64
end

struct Mesh2D
    cells::Array{Cell2D}
end

function create_mesh(nx::Int, ny::Int, x::Array{Float64}, y::Array{Float64})
    cells = Array{Cell2D}(undef, nx, ny)
    for i in 1:nx
        for j in 1:ny
            cell = Cell2D(x[i], x[i+1], y[j], y[j+1])
            cells[i, j] = cell
        end
    end
    return Mesh2D(cells)
end

function get_cell_points(mesh::Mesh2D, i::Int, j::Int)
    cell = mesh.cells[i, j]
    x_points = (cell.x1 + cell.x2) / 2
    y_points = (cell.y1 + cell.y2) / 2
    return x_points, y_points
end

function get_face_points(mesh::Mesh2D, i::Int, j::Int, direction::Symbol)
    cell = mesh.cells[i, j]
    if direction == :x
        x_points = (cell.x1 + cell.x2) / 2
        y_points = cell.y1
    elseif direction == :y
        x_points = cell.x1
        y_points = (cell.y1 + cell.y2) / 2
    end
    return x_points, y_points
end

function plot_mesh(mesh::Mesh2D)
    plot() # Initialise le tracé
    for i in 1:size(mesh.cells, 1)
        for j in 1:size(mesh.cells, 2)
            cell = mesh.cells[i, j]
            # Tracer les lignes de la grille
            plot!([cell.x1, cell.x2, cell.x2, cell.x1, cell.x1], [cell.y1, cell.y1, cell.y2, cell.y2, cell.y1], color=:black, legend=false, title="2D Mesh")
            # Tracer les centres des cellules
            scatter!([(cell.x1 + cell.x2) / 2], [(cell.y1 + cell.y2) / 2], color=:red, markersize=2)
            # Tracer les nœuds de la grille
            scatter!([cell.x1, cell.x2], [cell.y1, cell.y2], color=:blue, markersize=2)
        end
    end
    display(plot)
end