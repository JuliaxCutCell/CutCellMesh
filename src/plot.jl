"""
    plot_mesh(mesh::Tuple{Vector{T}}) where T <: Number

Plot a 1D mesh.

# Arguments
- `mesh::Tuple{Vector{T}}`: A tuple containing the x-coordinates of the mesh.

# Returns
- `p`: A plot object representing the 1D mesh.

"""
function plot_mesh(mesh::Tuple{Vector{T}}) where T <: Number
    x = mesh[1]
    p = plot(x, zeros(length(x)), seriestype=:scatter, legend=false, title="1D Mesh")
    return p
end


"""
    plot_mesh(mesh::Tuple{Vector{T}, Vector{T}}) where T <: Number

Plot a 2D mesh given by the `mesh` tuple.

# Arguments
- `mesh::Tuple{Vector{T}, Vector{T}}`: A tuple containing the x and y coordinates of the mesh.

# Returns
- `p::Plots.Plot`: A plot object representing the 2D mesh.
"""
function plot_mesh(mesh::Tuple{Vector{T}, Vector{T}}) where T <: Number
    x, y = mesh
    p = plot(legend=false, title="2D Mesh")
    for i in x
        plot!([i, i], [minimum(y), maximum(y)], color=:black)
    end
    for j in y
        plot!([minimum(x), maximum(x)], [j, j], color=:black)
    end
    return p
end


"""
    plot_mesh(mesh::Tuple{Vector{T}, Vector{T}, Vector{T}}) where T <: Number

Plot a 3D mesh given by `mesh`, which is a tuple of three vectors representing the x, y, and z coordinates.

# Arguments
- `mesh::Tuple{Vector{T}, Vector{T}, Vector{T}}`: A tuple of three vectors representing the x, y, and z coordinates of the mesh.

# Returns
- `p::Plots.Plot`: A plot object representing the 3D mesh.
"""
function plot_mesh(mesh::Tuple{Vector{T}, Vector{T}, Vector{T}}) where T <: Number
    x, y, z = mesh
    p = plot(legend=false, title="3D Mesh")
    for i in x
        for j in y
            plot!([i, i], [j, j], [minimum(z), maximum(z)], color=:black)
        end
    end
    for i in x
        for k in z
            plot!([i, i], [minimum(y), maximum(y)], [k, k], color=:black)
        end
    end
    for j in y
        for k in z
            plot!([minimum(x), maximum(x)], [j, j], [k, k], color=:black)
        end
    end
    return p
end