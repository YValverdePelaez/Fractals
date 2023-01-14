module Graphics

include("Maths.jl")

using Images

const save_dir = "../images/"
const white = [1, 1, 1];

export white                            #Constants
export draw, draw_segment!, draw_point! #Methods

function draw_point!(image, coords::Vector{Int64}, thickness, color)
    hmax = length(image[1, :, 1])
    vmax = length(image[1, 1, :])

    y_range = max(1, coords[2]-thickness):min(hmax, coords[2]+thickness)
    x_range = max(1, coords[1]-thickness):min(vmax, coords[1]+thickness)
    for y in y_range
        for x in x_range
            image[:, y, x] = color;
        end
    end
end

function draw_segment!(image, p1::Vector{Float64}, p2::Vector{Float64}, thickness, color)
    dist = p2 .- p1
    dir = Maths.normalize(dist)
    step = max((2*thickness), 1) .* dir
    pos = copy(p1)                                                  #Important to avoid changing the original vertices

    reps=0
    mag_dist = Maths.mag(dist)                                      #Compute scalar distance once per function call instead of every loop
    while reps<mag_dist
        draw_point!(image, ceil.(Int64, pos), thickness, color)
        pos .+= step
        reps+=1
    end
end

function draw(verts::Vector{Vector{Float64}}; width=1280, height=720, thickness=2, color=white, format="BMP", file_name="default", close_figure=true)
    image = ones(Float64, (3, height, width))

    next_index = 2
    for v in verts[1:end-1]
        p1=v;
        p2=verts[next_index];
        draw_segment!(image, p1, p2, thickness, color)
        next_index += 1
    end
    if close_figure
        p1 = verts[end]
        p2 = verts[1]
        draw_segment!(image, p1, p2, thickness, color)
    end

    file = string(save_dir, file_name, ".", lowercase(format))
    save(file, colorview(RGB, image))
end

end