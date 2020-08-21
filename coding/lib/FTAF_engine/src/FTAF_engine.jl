# Module
module FTAF_engine

# Encapsulate all interface in a shorter namespace
module eng
    # Module imports
    using Serialization
    using Reexport
    @reexport using Unitful
    @reexport using IntervalArithmetic
    @reexport using Measurements

    # Package interface
    include("interface.jl")

    # Package types
    include("types.jl")
# module eng
end

export eng

# Module
end
