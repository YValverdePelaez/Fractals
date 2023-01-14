import Pkg;
Pkg.add("Images")
Pkg.add("Colors")
Pkg.add("ColorSchemes")

using Images, Colors, ColorSchemes

# Functions to generate the Mandelbrot set,
# the set of complex numbers 'c' such that
# for the series S with z₀=0+0i never diverge
# S: 'zₙ₊₁ = zₙ² + c'

const BLACK = [0, 0, 0]

"""
    test_num(c, max_iter)

Test wether c is in Mandelbrot's set.

Tests wether a given number 'c' converges within a set number of iterations 'max_iter'.
This occurs when |zₙ| >= 2.

# Arguments
- `c::Complex`: Complex number to test.
- `max_iter::Integer`: Maximum number of iterations of the series tested.

# Return Value
Returns the number of iterations until non-divergence is proved and max_iter+1 if it never does
"""
function test_num(c::Complex, max_iter::Integer)::Integer
    z = 0+0im;
    i = 1;
    while i <= max_iter
        z = z*z + c
        if(abs2(z) >= 4)                     #use abs² and 2²for efficency
            break;
        end
        i += 1;       
    end
    return i;
end

"""
    get_color(color_scheme, iter, max_iter)

Maps a number 'iter' (presumably the iterations outputed by test_num) to a color
in the given 'color_scheme'.

# Arguments
- `color_scheme::ColorScheme`: Color scheme to map to.
- `iter::Integer`: The input number whose mapped value is outputed.
- `max_iter::Integer`: Maximum input, maps to one end of the color scheme's range of colors.

# Return Value
Returns an array with the rgb values of the mapped color, black for any out of bounds.
"""
function get_color(color_scheme::ColorScheme, iter::Integer, max_iter::Integer)
    if iter > max_iter
        return BLACK
    else
        color = get(color_scheme, iter, (1, max_iter))
        return [color.r, color.g, color.b]
    end
end

"""
    gen_mandelbrot(width, height; max_iter, format, file_name)

Generates an image of the Mandelbrot Set.

Generates an image ['file_name].['format'] of dimensions ('width', 'height') of
the Mandelbrot Set by testing for all values within range a maximum of 'max_iter'
times employing the 'test_num' method. Stores it in ./images

#Arguments
- `width::Integer`: Width in pixels of the image. Defaults to 1280 (72ppi resolution).
- `height::Integer`: Height in pixels of the image. Defaults to 720 (72ppi resolution).
- `max_iter::Integer`: Maximum number of itertions of the test performed to check wether a number is part of the set. "Depth" of search, "precision".
Defaults to 50
- `format::String`: Format of the output image (Tested: JPEG, PNG, PDF, BMP(Recomended)). Defaults to .BMP
- `file_name::String`: Name to store the image under. Defaults to "Mandelbrot"

#See also
- [`test_num`](@Main.jl)
"""
function gen_mandelbrot(width::Integer=1280, height::Integer=720 ;max_iter::Integer=50, format::String="BMP", file_name::String="Mandelbrot")

    steps = zeros(Int, (height, width));

    #range for real values
    r_min = -3.0
    r_max = 2.0

    #range for imaginay values
    i_min = -1.3

    range = r_max - r_min
    px_size = range/width;
    i_max = i_min + height*px_size;

    image = zeros(Float64, (3, height, width))
    color_scheme = ColorSchemes.linear_blue_5_95_c73_n256
    y = 1
    for ci=i_min:px_size:i_max-px_size
        x = 1
        for cr=r_min:px_size:r_max-px_size
            c = Complex(cr, ci)
            image[:, y, x] = get_color(color_scheme, test_num(c, max_iter), max_iter);
            x+=1
        end
        y+=1
    end

    file = string("images/", file_name, ".", lowercase(format))
    save(file, colorview(RGB, image))
end
