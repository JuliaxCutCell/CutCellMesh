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

end # module CutCellMesh