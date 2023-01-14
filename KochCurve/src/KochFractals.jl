module KochFractals

import Pkg; Pkg.add("Images")

include("Maths.jl")
include("Graphics.jl")

using Images
using Main.KochFractals.Maths
using Main.KochFractals.Graphics

export koch_curve, koch_snowflake

"""
    koch_segment(p1, p2)

For the segment between p1 and p2 calculate additional vertices according to the Koch Fractal's defining algorithm

For the segment 's' between `p1` and `p2` place two vertices at (1/3)s (`p3`) and (2/3)s (`p5`) and
a third one in the middle but raised (√3/2)(1/3)l (`p4`) (making an equilateral triangle),
removing the segment between `p3` and `p5` so that the distance between all points is the same and 1/3 of
distance between the original two points

# Arguments
- `p1::Vector{Float64}`: The first point in pixel coordinates.
- `p2::Vector{Float64}`: The second point in pixel coordinates.

# Returned Value
Returns a length 5 array of 2-dimensional points each represented by a length 2 vector of Float64.
"""
function koch_segment(p1::Vector{Float64}, p2::Vector{Float64})::Vector{Vector{Float64}}
    dist = p2 .- p1                     # Distance between points (vector)
    dir = normalize(dist)               # Direction from p1 to p2 (vector)
    norm = [dir[2], -dir[1]]            # Normal vector of the segment
    p3 = p1 .+ (dist ./ 3)
    p5 = p1 .+ ((2 .* dist) ./ 3)
    p4 = p1 .+ ((dist ./ 2) .+ (mag(dist) / 3 * sqrt3_halves .* norm))

    return [p1, p3, p4, p5, p2]
end

"""
    koch_curve(vertices; iter, width, height, thickness, color, format, file_name)

Generates the vertices for a given iteration `iter` of Koch's curve with the starting vertices `vertices`
and draws them into an image.

Recursive algorithm to perform the defining algorithm of Koch's fractal (as described and implemented
in `koch_segment(p1, p2)`) on every pair of points in `vertices` a given number of iterations `iter`.
\n
Draws (with `Graphics.draw()` the generated vertices connected by lines of color `color` into an image
`file_name`.`format` of dimensions `width`*`height` stored in [WorkingDirectory]/images.

# Arguments
- `vertices::Vector{Vector{Float64}}`: An array of length 2 Float64 vectors representing
    vertices of segments on which to perform the algorithm implemented in `koch_segment(p1, p2)`.
- `iter`: Keyword argument to determine the number of iterations for which to generate a koch curve. Defaults to 5.
- `width`: Length on the X axis of the generated image. Defaults to 2048.
- `height`: Length on the Y axis of the generated image. Defaults to 2048.
- `thickness`: Additional pixels colored around any pixel to be drawn such that a thickness of 1 means a point will
    be drawn as a 3*3 square of pixels. Defaults to 0.
- `color`: Color of the points and segments drawn. Defaults to the `Graphics.white` constant ([1, 1, 1])
- `format`: Format of the output image, appended in lowercase (after a dot) at the end of the file name. Defaults to "BMP"
- `file_name`: Name of the ouput image. Defaults to "koch_curve"

# Warning
No checks are performed to make sure any vertices are inside the specified dimensions of the image.

# Returned Value
Returns an array of points each represented by a length 2 vector of Float64.\n
The length of the container array will be given by m·4ⁿ+1 where m is the length of the original vertices-1, and n is `iter`.\n
Note then that for a Koch curve computed from a single starting segment (2 vertices) the number of vertices is given by 4ⁿ+1

# See also
- [`koch_segment`](@Main.KochFractals.jl)

"""
function koch_curve(vertices::Vector{Vector{Float64}}; iter=5, width=2048, height=2048, thickness=0, color=Graphics.white, format="BMP", file_name="koch_curve")::Vector{Vector{Float64}}
    out_length = 4*(length(vertices)-1)+1
    out_vertices = fill(vectorzero, out_length)

    #Group every two points into a segment and perform koch_segment on them
    index = 0
    for v in vertices[1:end-1]
        index += 1
        start_index = 4*(index-1)+1
        finish_index = start_index+4
        out_vertices[start_index:finish_index] = koch_segment(v, vertices[index+1])
    end

    #If this is the last step in the recursion draw the generated vertices, if it isn't generate the remaining vertices and test again
    if iter == 1
        Graphics.draw(out_vertices, width=width, height=height, thickness=thickness, color=color, format=format, file_name=file_name, close_figure=false)
    else
        koch_curve(out_vertices, iter=iter-1, width=width, height=height, thickness=thickness, color=color, format=format, file_name=file_name)
    end

    return out_vertices
end

"""
    koch_snowflake(iter; square_dims, thickness, color, format, file_name)

Creates a koch snowflake centered and scaled to fit the specified dimensions.

Sets three starting vertices making an equilateral triangle and a fourth identical to the first to close it.
The length of the side is (√3/2)*height so that when the first iterations is done (a six pointed star) the maximum
height of this star equals the height of the image ensuring that for all iterations the snowflake just fits.
Once the starting vertices are set `koch_curve()` is called to recursively generate and draw the fractal.

# Arguments
- `iter::Int64`: Number of iterations for which to generate Koch's snowflake.
- `square_dims`: Width and height of the square image generated given as a single number. Defaults to 2048.
- `thickness`: Additional pixels colored around any pixel to be drawn such that a thickness of 1 means a point will
    be drawn as a 3*3 square of pixels. Defaults to 0.
- `color`: Color of the points and segments drawn. Defaults to the `Graphics.white` constant ([1, 1, 1]).
- `format`: Format of the output image, appended in lowercase (after a dot) at the end of the file name. Defaults to "BMP".
- `file_name`: Name of the ouput image. Defaults to "koch_snowflake".

# Warning
- Vertices calculated and time grow exponentially (vertices=3*4ⁿ), 5 iterations is normally more than enough.
- Multiplying dimensions by a factor of n multiplies time by about 5ⁿ⁻¹ although this varies greatly.

# See also
- [`koch_segment`](@Main.KochFractals.jl)
- [`koch_curve`](@Main.KochFractals.jl)

"""
function koch_snowflake(iter::Int64;square_dims=2048, thickness=0, color=Graphics.white, format="BMP", file_name="koch_snowflake")
    l = sqrt3_halves*square_dims
    v_sep = sqrt3_halves*(l/3)
    h_sep = (square_dims-l)/2
    vertices = [[h_sep, v_sep], [h_sep+l, v_sep], [square_dims/2, square_dims], [h_sep, v_sep]]

    koch_curve(vertices, iter=iter, width=square_dims, height=square_dims, thickness=thickness, color = color, format=format, file_name=file_name)
end

end