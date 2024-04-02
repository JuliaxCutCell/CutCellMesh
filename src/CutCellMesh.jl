module CutCellMesh

using Interpolations
using Plots
Plots.default(show = true)

# Include files
include("mesh.jl")
include("plot.jl")

# Export functions
export CartesianGrid, generate_mesh
export plot_mesh
export interpolate_values

end # module CutCellMesh