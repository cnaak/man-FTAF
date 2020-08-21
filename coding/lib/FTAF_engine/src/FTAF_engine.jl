# Module
module FTAF_engine

# Encapsulate all interface in a shorter namespace ...
module eng

    # Module imports
    using Serialization
    using Unitful
    using IntervalArithmetic
    using Measurements

    # Package interface
    include("interface.jl")

    # Package types
    include("types.jl")

end

# ... then export it
export eng

# Module
end

