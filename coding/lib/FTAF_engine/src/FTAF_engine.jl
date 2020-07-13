# Module
module FTAF_engine

# Package interface
include("interface.jl")

# Module imports
using Reexport
@reexport using IntervalArithmetic

# Package types
include("types.jl")

# Module
end
