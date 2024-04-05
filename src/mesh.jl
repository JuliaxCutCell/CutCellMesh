struct InvalidDimensionException{N} <: Exception end

Base.showerror(io::IO, ::InvalidDimensionException{N}) where {N} = print(io, "Dimension is not valid: $(N).")

"""
    struct CartesianGrid{N,I<:Integer,T<:Number}

A struct representing a Cartesian grid in N-dimensional space.

# Fields
- `n::NTuple{N,I}`: The number of grid points in each dimension.
- `spacing::NTuple{N,T}`: The spacing between grid points in each dimension.

# Constructors
- `CartesianGrid(n::NTuple{N,I}, spacing::NTuple{N,T})`: Constructs a CartesianGrid object with the given number of grid points and spacing.

"""
struct CartesianGrid{N,I<:Integer,T<:Number}
    n::NTuple{N,I}
    spacing::NTuple{N,T}

    function CartesianGrid(n::NTuple{N,I}, spacing::NTuple{N,T}) where {N,I<:Integer,T<:Number}
        0 < N < 4 || throw(InvalidDimensionException{N}())
        new{N,I,T}(n, spacing)
    end
end
Base.ndims(::CartesianGrid{N}) where {N} = N
Base.size(grid::CartesianGrid) = grid.n
spacing(grid::CartesianGrid) = grid.spacing
calculate_volume(grid::CartesianGrid) = prod(size(grid)) * prod(spacing(grid))
calculate_surface(grid::CartesianGrid) = 2 * sum(spacing(grid)) * prod(size(grid) .- 1)
total_cells(grid::CartesianGrid) = prod(size(grid))

"""
    generate_mesh(grid::CartesianGrid{N,I}, staggered::Bool=false) where {N,I}

Generate a mesh for the given Cartesian grid.

# Arguments
- `grid::CartesianGrid{N,I}`: The Cartesian grid for which to generate the mesh.
- `staggered::Bool=false`: Whether to generate a staggered mesh. Default is `false`.

# Returns
- An array representing the generated mesh.
"""
function generate_mesh(grid::CartesianGrid{N,I}, staggered::Bool=false) where {N,I}
    lo = zero(I)

    if staggered
        map(size(grid), spacing(grid)) do n, h
            [h/2 + i*h for i in 0:n]
        end
    else
        map(size(grid), spacing(grid)) do n, h
            [i*h for i in 0:n]
        end
    end
end

"""
    cell_boundary_indices(grid::CartesianGrid)

Compute the indices of the boundary cells in a Cartesian grid.

# Arguments
- `grid::CartesianGrid`: The Cartesian grid.

# Returns
An array of boolean values indicating whether each cell is on the boundary or not.

"""
function cell_boundary_indices(grid::CartesianGrid)
    map(size(grid)) do n
        [i == 1 || i == n for i in 1:n]
    end
end

"""
    cell_volumes(grid::CartesianGrid)

Compute the volumes of the cells in a Cartesian grid.

# Arguments
- `grid::CartesianGrid`: The Cartesian grid.

# Returns
- An array of cell volumes.

"""
function cell_volumes(grid::CartesianGrid)
    map(size(grid), spacing(grid)) do n, h
        [h^2 for i in 1:n]
    end
end

"""
    get_edges(maillage)

Given a mesh `mesh``, this function returns a list of edges representing the boundary of the mesh.

# Arguments
- `mesh`: A tuple or array of arrays representing the coordinates of the mesh points.

# Returns
- `edges`: A list of edges, where each edge is represented as a pair of points.

"""
function get_edges(mesh)
    dim = length(mesh)

    edges = []
    if dim == 1
        x = mesh[1]
        for i in 1:length(x)-1
            push!(edges, [x[i]])
        end
    elseif dim == 2
        x, y = mesh
        for i in 1:length(x)-1
            for j in 1:length(y)-1
                push!(edges, [[x[i], y[j]], [x[i+1], y[j]]])
                push!(edges, [[x[i], y[j]], [x[i], y[j+1]]])
            end
        end
    elseif dim == 3
        x, y, z = mesh
        for i in 1:length(x)-1
            for j in 1:length(y)-1
                for k in 1:length(z)-1
                    push!(edges, [[x[i], y[j], z[k]], [x[i+1], y[j], z[k]]])
                    push!(edges, [[x[i], y[j], z[k]], [x[i], y[j+1], z[k]]])
                    push!(edges, [[x[i], y[j], z[k]], [x[i], y[j], z[k+1]]])
                end
            end
        end
    else
        error("Unsupported mesh dimension: $dim")
    end

    return edges
end