#!/usr/bin/env julia
cd("src/")
include("src/KochFractals.jl")
KochFractals.koch_snowflake(5)
