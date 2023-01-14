module Maths

export sqrt3_halves, vectorzero #All constants
export mag, normalize           #All methods

const sqrt3_halves = sqrt(3)/2  #√(3)/2
const vectorzero = [0.0, 0.0];

mag(v::Vector{Float64}) = sqrt(v[1]^2 + v[2]^2)
normalize(v::Vector{Float64}) = v./mag(v)

end