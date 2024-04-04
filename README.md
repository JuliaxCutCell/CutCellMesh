# CutCellMesh

## Overview
This repository contains tools for the generation of 1D, 2D and 3D structured meshes

## Usage
```
# Creation of a 2D Cartesian grid with 10 points in x and 20 points in y
grid = CartesianGrid((10, 20), (0.1, 0.05))

# Display grid dimensions
println("Dimensions de la grille :", ndims(grid))

# Display grid size
println("Taille de la grille :", size(grid))

# Display spacing between grid points
println("Espacement entre les points de la grille :", spacing(grid))

# Grid volume calculation
println("Volume de la grille :", calculate_volume(grid))

# Generating a mesh from the grid
mesh = generate_mesh(grid)

# Mesh display
println("Maillage généré :", mesh)
```


## ToDo
- TensorMesh (classique) : Padding element, Area Plot (log) 
- Data Structure : TreeMesh
- Space Filling Curve for MPI
- AMR (Quadtree/Octree)