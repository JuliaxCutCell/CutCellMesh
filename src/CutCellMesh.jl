module CutCellMesh

using Interpolations
using Plots
Plots.default(show = true)

# Include files
include("mesh.jl")
include("plot.jl")
include("utils.jl")

# Export functions
export CartesianGrid, generate_mesh, cell_boundary_indices, cell_volumes, get_edges
export plot_mesh
export interpolate_values


# Cas 1D
grid = CartesianGrid((10,), (0.1,))
mesh = generate_mesh(grid)
@show mesh

plot_mesh(mesh)
readline()

edge = get_edges(mesh)
@show edge

# Cas 2D
grid = CartesianGrid((10, 10), (0.1, 0.1))
mesh = generate_mesh(grid)
@show mesh

edge = get_edges(mesh)
@show edge

"""
# Cas 3D
grid = CartesianGrid((10, 10, 10), (0.1, 0.1, 0.1))
mesh = generate_mesh(grid)
@show mesh

node = nodes(grid)
@show node

"""



#plot_mesh(mesh)
#readline()
end # module CutCellMesh