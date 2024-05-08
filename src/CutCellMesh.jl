module CutCellMesh

using Plots
Plots.default(show = true)

# Include files
include("mesh.jl")
include("plot.jl")

# Export functions
export CartesianMesh, nodes, centers, edges, faces
export plot_grid


end # module CutCellMesh