using CutCellMesh
using Plots
Plots.default(show = true)
# Cas 1D
grid = CartesianGrid((10,), (0.1,))
mesh = generate_mesh(grid)
plot_mesh(mesh)
values = [sin(x) for x in mesh[1]]
@show interpolate_values(mesh, values, (0.5,))

# Cas 2D
grid = CartesianGrid((10, 10), (0.1, 0.1))
mesh = generate_mesh(grid)
plot_mesh(mesh)
values = [sin(x) + cos(y) for x in mesh[1], y in mesh[2]]
@show interpolate_values(mesh, values, (0.5, 0.5))

# Cas 3D
grid = CartesianGrid((10, 10, 10), (0.1, 0.1, 0.1))
mesh = generate_mesh(grid)
plot_mesh(mesh)
values = [sin(x) + cos(y) + tan(z) for x in mesh[1], y in mesh[2], z in mesh[3]]
@show interpolate_values(mesh, values, (0.5, 0.5, 0.5))

grid = CartesianGrid((10,10), (0.1, 0.1))
println(total_cells(grid))  # Affiche 100
mesh = generate_mesh(grid)
plot_mesh(mesh)
readline() 

println(cell_centers(grid))  # Affiche les coordonnées des centres des cellules

println(cell_boundary_indices(grid))  # Affiche un tableau booléen indiquant les cellules de la frontière

println(cell_volumes(grid))  # Affiche les volumes des cellules
