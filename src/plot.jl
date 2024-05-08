function plot_grid(mesh::CartesianMesh{1}; act_nodes=true, act_centers=true, act_edges=true, act_faces=true)
    # 1D plot

    p = plot(layout = (1, 3), size = (1450, 500))

    # Calculer les coordonnées des noeuds, des centres, des arêtes et des faces
    x_nodes = nodes(mesh)
    x_centers = centers(mesh)
    x_edges = edges(mesh)
    x_faces = faces(mesh)

    # Tracer la grille en arrière-plan pour chaque disposition
    x_nodes_arr = first(x_nodes)
    for k in 1:3
        for i in 1:length(x_nodes_arr)-1
            plot!(p[k], [x_nodes_arr[i], x_nodes_arr[i+1]], [0, 0], color=:black, label=false)
        end
    end

    # Tracer les noeuds et les centres des cellules
    if act_nodes
        scatter!(p[1], x_nodes, zeros(length(x_nodes)), label="Nodes", marker=:square, color=:blue)
    end
    if act_centers
        scatter!(p[1], x_centers, zeros(length(x_centers)), label="Centers", marker=:square, color=:orange)
    end

    # Tracer les arêtes des cellules
    if act_edges
        scatter!(p[2], x_edges, zeros(length(x_edges)), label="Edges", marker=:rtriangle, color=:blue)
    end

    # Tracer les faces des cellules
    if act_faces
        scatter!(p[3], x_faces, zeros(length(x_faces)), label="Faces", marker=:rtriangle, color=:green)
    end

    return p
end

function plot_grid(mesh::CartesianMesh{2}; act_nodes=true, act_centers=true, act_edges=true, act_faces=true)
    # 2D plot

    p = plot(layout = (1, 3), size = (1450, 500))

    # Calculer les coordonnées des noeuds, des centres, des arêtes et des faces
    x_nodes, y_nodes = nodes(mesh)
    x_centers, y_centers = centers(mesh)
    x_edges, y_edges = edges(mesh)
    x_faces, y_faces = faces(mesh)

    # Tracer la grille en arrière-plan pour chaque disposition
    for k in 1:3
        for (i, x) in enumerate(x_nodes)
            for (j, y) in enumerate(y_nodes)
                if i < length(x_nodes) plot!(p[k], [x, x_nodes[i+1]], [y, y], color=:black, label=false) end
                if j < length(y_nodes) plot!(p[k], [x, x], [y, y_nodes[j+1]], color=:black, label=false) end
            end
        end
    end

    # Tracer les noeuds et les centres des cellules
    if act_nodes
        scatter!(p[1], repeat(x_nodes, inner=length(y_nodes)), repeat(y_nodes, outer=length(x_nodes)), label="Nodes", marker=:square, color=:blue)
    end
    if act_centers
        scatter!(p[1], repeat(x_centers, inner=length(y_centers)), repeat(y_centers, outer=length(x_centers)), label="Centers", marker=:square, color=:orange)
    end

    # Tracer les arêtes des cellules
    if act_edges
        scatter!(p[2], repeat(x_nodes, inner=length(y_edges)), repeat(y_edges, outer=length(x_nodes)), label="X-Edges", marker=:rtriangle, color=:blue)
        scatter!(p[2], repeat(x_edges, inner=length(y_nodes)), repeat(y_nodes, outer=length(x_edges)), label="Y-Edges", marker=:utriangle, color=:red)
    end

    # Tracer les faces des cellules
    if act_faces
        scatter!(p[3], repeat(x_nodes, inner=length(y_faces)), repeat(y_faces, outer=length(x_nodes)), label="X-Faces", marker=:rtriangle, color=:green)
        scatter!(p[3], repeat(x_faces, inner=length(y_nodes)), repeat(y_nodes, outer=length(x_faces)), label="Y-Faces", marker=:utriangle, color=:purple)
    end
end

function plot_grid(mesh::CartesianMesh{3}; act_nodes=true, act_centers=true, act_edges=true, act_faces=true)
    # 3D plot

    p = plot(layout = (1, 3), size = (1450, 500))

    # Calculer les coordonnées des noeuds, des centres, des arêtes et des faces
    x_nodes, y_nodes, z_nodes = nodes(mesh)
    x_centers, y_centers, z_centers = centers(mesh)
    x_edges, y_edges, z_edges = edges(mesh)
    x_faces, y_faces, z_faces = faces(mesh)

    # Tracer la grille en arrière-plan pour chaque disposition
    for l in 1:3 
        for (i, x) in enumerate(x_nodes)
            for (j, y) in enumerate(y_nodes)
                for (k, z) in enumerate(z_nodes)
                    if i < length(x_nodes) plot!(p[l], [x, x_nodes[i+1]], [y, y], [z, z], color=:black, label=false) end  # Use 'l' here
                    if j < length(y_nodes) plot!(p[l], [x, x], [y, y_nodes[j+1]], [z, z], color=:black, label=false) end  # Use 'l' here
                    if k < length(z_nodes) plot!(p[l], [x, x], [y, y], [z, z_nodes[k+1]], color=:black, label=false) end  # Use 'l' here
                end
            end
        end
    end

    # Tracer les noeuds et les centres des cellules
    if act_nodes
        scatter!(p[1], repeat(x_nodes, inner=length(y_nodes), outer=length(z_nodes)), repeat(y_nodes, outer=length(x_nodes), inner=length(z_nodes)), repeat(z_nodes, outer=length(x_nodes), inner=length(y_nodes)), label="Nodes", marker=:square, color=:blue)
    end
    if act_centers
        scatter!(p[1], repeat(x_centers, inner=length(y_centers), outer=length(z_centers)), repeat(y_centers, outer=length(x_centers), inner=length(z_centers)), repeat(z_centers, outer=length(x_centers), inner=length(y_centers)), label="Centers", marker=:square, color=:orange)
    end

    # Tracer les arêtes des cellules
    if act_edges
        scatter!(p[2], repeat(x_nodes, inner=length(y_edges), outer=length(z_edges)), repeat(y_edges, outer=length(x_nodes), inner=length(z_edges)), repeat(z_edges, outer=length(x_nodes), inner=length(y_edges)), label="X-Edges", marker=:rtriangle, color=:blue)
        scatter!(p[2], repeat(x_edges, inner=length(y_nodes), outer=length(z_edges)), repeat(y_nodes, outer=length(x_edges), inner=length(z_edges)), repeat(z_edges, outer=length(x_edges), inner=length(y_nodes)), label="Y-Edges", marker=:utriangle, color=:red)
        scatter!(p[2], repeat(x_edges, inner=length(y_edges), outer=length(z_nodes)), repeat(y_edges, outer=length(x_edges), inner=length(z_nodes)), repeat(z_nodes, outer=length(x_edges), inner=length(y_edges)), label="Z-Edges", marker=:dtriangle, color=:green)
    end

    # Tracer les faces des cellules
    if act_faces
        scatter!(p[3], repeat(x_nodes, inner=length(y_faces), outer=length(z_faces)), repeat(y_faces, outer=length(x_nodes), inner=length(z_faces)), repeat(z_faces, outer=length(x_nodes), inner=length(y_faces)), label="X-Faces", marker=:rtriangle, color=:blue)
        scatter!(p[3], repeat(x_faces, inner=length(y_nodes), outer=length(z_faces)), repeat(y_nodes, outer=length(x_faces), inner=length(z_faces)), repeat(z_faces, outer=length(x_faces), inner=length(y_nodes)), label="Y-Faces", marker=:utriangle, color=:red)
        scatter!(p[3], repeat(x_faces, inner=length(y_faces), outer=length(z_nodes)), repeat(y_faces, outer=length(x_faces), inner=length(z_nodes)), repeat(z_nodes, outer=length(x_faces), inner=length(y_faces)), label="Z-Faces", marker=:dtriangle, color=:green)
    end
end