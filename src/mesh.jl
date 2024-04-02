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