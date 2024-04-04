using LinearAlgebra
using Plots

struct Mesh
    h::Tuple
    origin::Array{Float64,1}
    Mesh(h; origin=[0.0, 0.0, 0.0]) = new(h, origin)
end

function plot_grid(mesh::Mesh)
    hx, hy = mesh.h
    x = cumsum(hx) .- hx[1]/2
    y = cumsum(hy) .- hy[1]/2
    plot(grid = true, xlims = (0, sum(hx)), ylims = (0, sum(hy)), aspect_ratio = :equal)
    for i in x
        plot!([i, i], [0, sum(hy)], color = :black)
    end
    for j in y
        plot!([0, sum(hx)], [j, j], color = :black)
    end
    display(plot!())
end

function pad_cells(n::Int, d::Float64, exp::Float64)
    return [d * exp^(i-1) for i in 1:n]
end

# Exemple d'utilisation
ncx, ncy = 10, 10
dx, dy = 10.0, 10.0
npad_x, npad_y = 5, 5
exp_x, exp_y = 1.3, 1.3
hx = [dx for i in 1:npad_x]
hy = [dy for i in 1:npad_y]
hx = pad_cells(ncx - npad_x, dx, exp_x)
hy = pad_cells(ncy - npad_y, dy, exp_y)
mesh = Mesh((hx, hy), origin=[0.0, 0.0])
plot_grid(mesh)
readline()

x0 = mesh.origin[1]
y0 = mesh.origin[2]

nCx, nCy = nC(mesh)