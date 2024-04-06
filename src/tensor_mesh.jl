using Plots
Plots.default(show = true)
abstract type AbstractMesh{N, T} end

struct InvalidDimensionException{N} <: Exception end

Base.showerror(io::IO, ::InvalidDimensionException{N}) where {N} = print(io, "Dimension is not valid: $(N).")

struct CartesianMesh{N, T} <: AbstractMesh{N, T}
    # The mesh is defined by the spacing in each dimension
    spacing::NTuple{N, Vector{T}}
    # The position of the bottom-left corner of the mesh
    origin::NTuple{N, T}

    function CartesianMesh(spacing::NTuple{N, Vector{T}}, origin::NTuple{N, T}) where {N, T}
        0 < N < 4 || throw(InvalidDimensionException{N}())
        new{N, T}(spacing, origin)
    end
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
function volume_cell(mesh::CartesianMesh)
    # Determine the dimension of the mesh
    dim = length(mesh.spacing)

    # Calculate the volume (3D), area (2D), or length (1D) of each cell individually
    if dim == 1
        volume_array = mesh.spacing[1]
    elseif dim == 2
        volume_array = zeros(length(mesh.spacing[1]), length(mesh.spacing[2]))
        for i in 1:length(mesh.spacing[1])
            for j in 1:length(mesh.spacing[2])
                volume_array[i, j] = mesh.spacing[1][i] * mesh.spacing[2][j]
            end
        end
    elseif dim == 3
        volume_array = zeros(length(mesh.spacing[1]), length(mesh.spacing[2]), length(mesh.spacing[3]))
        for i in 1:length(mesh.spacing[1])
            for j in 1:length(mesh.spacing[2])
                for k in 1:length(mesh.spacing[3])
                    volume_array[i, j, k] = mesh.spacing[1][i] * mesh.spacing[2][j] * mesh.spacing[3][k]
                end
            end
        end
    else
        error("Unsupported mesh dimension: $dim")
    end
    
    return volume_array
end

function plot_cell_volumes(sf::Array)
    dim = length(size(sf))

    if dim == 1
        plot(sf, title="Volume des cellules 1D", label="Volume")
    elseif dim == 2
        heatmap(sf, aspect_ratio=1, color=:viridis, title="Volume des cellules 2D")
    elseif dim == 3
        for i in 1:size(sf, 3)
            heatmap(sf[:, :, i], aspect_ratio=1, color=:viridis, title="Volume des cellules 3D - Couche $i")
        end
    else
        error("Unsupported array dimension: $dim")
    end
end

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
sf = volume_cell(grid)
@show sf
plot_cell_volumes(sf)
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
sf = volume_cell(grid)
@show sf
plot_cell_volumes(sf)
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
sf = volume_cell(grid)
@show sf
plot_cell_volumes(sf)
readline()

# Cas test non Uniforme
nx, ny, nz = 10, 10, 10
dx, dy, dz = 1.0, 1.0, 1.0
hx = [1.0, 0.5, 0.5, 1.0, 1.0, 0.5, 0.5, 1.0, 1.0, 0.5]
hy = [1.0, 0.5, 0.5, 1.0, 1.0, 0.5, 0.5, 1.0, 1.0, 0.5]
hz = [1.0, 0.5, 0.5, 1.0, 1.0, 0.5, 0.5, 1.0, 1.0, 0.5]
origin = (0.0, 0.0, 0.0)
grid = CartesianMesh((hx, hy, hz), origin)
mesh = generate_mesh(grid)
sf = volume_cell(grid)
@show sf



