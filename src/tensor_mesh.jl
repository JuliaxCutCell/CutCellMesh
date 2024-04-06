using Plots
Plots.default(show = true)
abstract type AbstractMesh{N, T} end

# Define constants for variable locations
const NODES = 1
const CELL_FACES = 2
const CELL_EDGES = 3

struct CartesianMesh{N, T, L} <: AbstractMesh{N, T}
    # The mesh is defined by the spacing in each dimension
    spacing::NTuple{N, Vector{T}}
    # The position of the bottom-left corner of the mesh
    origin::NTuple{N, T}
    # The location of the variables
    location::L
end

function generate_mesh(mesh::CartesianMesh)
    if mesh.location == NODES
        # Generate the mesh for variables located at the nodes
        mesh_points = [[o + sum(s[1:i]) for i in 0:length(s)] for (s, o) in zip(mesh.spacing, mesh.origin)]
    elseif mesh.location == CELL_FACES
        # Generate the mesh for variables located at the cell faces
        mesh_points = [[o + sum(s[1:i]) - s[i]/2 for i in 1:length(s)] for (s, o) in zip(mesh.spacing, mesh.origin)]
    elseif mesh.location == CELL_EDGES
        # Generate the mesh for variables located at the cell edges
        mesh_points = [[o + sum(s[1:i]) - s[i]/2 for i in 1:length(s)] for (s, o) in zip(mesh.spacing, mesh.origin)]
    end
    return tuple(mesh_points...)
end

function generate_mesh(mesh::CartesianMesh, staggered::Bool=false)
    # Generate the mesh
    mesh_points = [[o + sum(s[1:i]) for i in 0:length(s)] for (s, o) in zip(mesh.spacing, mesh.origin)]
    return tuple(mesh_points...)
end

function total_cells(mesh::CartesianMesh)
    return prod([length(s) for s in mesh.spacing])
end

function plot_mesh(mesh::Tuple{Vector{T}}) where T <: Number
    x = mesh[1]
    p = plot(x, zeros(length(x)), seriestype=:scatter, legend=false, title="1D Mesh", color=:blue)
    return p
end
function plot_mesh(mesh::Tuple{Vector{T}, Vector{T}}) where T <: Number
    x, y = mesh
    p = scatter(legend=false, title="2D Mesh Centers")

    for (i, j) in Base.Iterators.product(x, y)
        scatter!(p, [i], [j], color=:blue)
    end

    return p
end
function plot_mesh(mesh::Tuple{Vector{T}, Vector{T}, Vector{T}}) where T <: Number
    x, y, z = mesh
    p = scatter(legend=false, title="3D Mesh Centers")

    for (i, j, k) in Base.Iterators.product(x, y, z)
        scatter!(p, [i], [j], [k], color=:blue)
    end

    return p
end

"""
# Exemple d'utilisation
# Cas 1D
nx = 10
dx = 1.0
hx = dx * ones(nx)
origin = (0.0,)
grid = CartesianMesh((hx,), origin)
mesh = generate_mesh(grid)
@show mesh
nc = total_cells(grid)
plot_mesh(mesh)
readline()

# Cas 2D
nx, ny  = 10, 10
dx, dy = 1.0, 1.0
hx, hy = dx * ones(nx), dy * ones(ny)
origin = (-1.0, 0.0)
grid = CartesianMesh((hx, hy), origin)
mesh = generate_mesh(grid, true)
nc = total_cells(grid)
plot_mesh(mesh)
readline()

# Cas 3D
nx, ny, nz = 10, 10, 10
dx, dy, dz = 1.0, 1.0, 1.0
hx, hy, hz = dx * ones(nx), dy * ones(ny), dz * ones(nz)
origin = (-1.0, 0.0, 0.0)
grid = CartesianMesh((hx, hy, hz), origin)
mesh = generate_mesh(grid)
nc = total_cells(grid)
#plot_mesh(mesh)
#readline()


# Cas test non Uniforme
nx = 10
hx = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
origin = (0.0,)
grid = CartesianMesh((hx,), origin)
mesh = generate_mesh(grid)
@show mesh
plot_mesh(mesh)
readline()
"""

nx, ny  = 10, 10
dx, dy = 1.0, 1.0
hx, hy = dx * ones(nx), dy * ones(ny)
origin = (0.0, 0.0)
grid = CartesianMesh((hx, hy), origin, CELL_EDGES)
mesh = generate_mesh(grid)
@show mesh