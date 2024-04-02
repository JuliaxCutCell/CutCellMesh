"""
    interpolate_values(mesh::Tuple{Vector{T}}, values::Vector{T}, x::Tuple{T}) where T <: Number

Interpolates values on a mesh using linear interpolation.

# Arguments
- `mesh::Tuple{Vector{T}}`: The mesh coordinates.
- `values::Vector{T}`: The values corresponding to the mesh coordinates.
- `x::Tuple{T}`: The coordinates at which to interpolate the values.

# Returns
- The interpolated value at the given coordinates.

"""
function interpolate_values(mesh::Tuple{Vector{T}}, values::Vector{T}, x::Tuple{T}) where T <: Number
    knots = mesh
    itp = interpolate(knots, values, Gridded(Linear()))
    return itp[x...]
end

"""
    interpolate_values(mesh::Tuple{Vector{T}, Vector{T}}, values::Matrix{T}, x::Tuple{T, T}) where T <: Number

Interpolates values on a mesh using linear interpolation.

# Arguments
- `mesh`: A tuple of two vectors representing the mesh knots.
- `values`: A matrix of values corresponding to the mesh knots.
- `x`: A tuple of two values representing the coordinates at which to interpolate.

# Returns
The interpolated value at the given coordinates.
"""
function interpolate_values(mesh::Tuple{Vector{T}, Vector{T}}, values::Matrix{T}, x::Tuple{T, T}) where T <: Number
    knots = mesh
    itp = interpolate(knots, values, Gridded(Linear()))
    return itp[x...]
end

"""
    interpolate_values(mesh, values, x)

Interpolates values on a mesh at a given point.

# Arguments
- `mesh`: A tuple of three vectors representing the mesh coordinates in each dimension.
- `values`: A 3D array of values corresponding to the mesh.
- `x`: A tuple of three values representing the coordinates of the point to interpolate.

# Returns
The interpolated value at the given point.
"""
function interpolate_values(mesh::Tuple{Vector{T}, Vector{T}, Vector{T}}, values::Array{T, 3}, x::Tuple{T, T, T}) where T <: Number
    knots = mesh
    itp = interpolate(knots, values, Gridded(Linear()))
    return itp[x...]
end

