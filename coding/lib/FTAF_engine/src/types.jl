#==============================================================================================#
#                                            Types                                             #
#==============================================================================================#

"""
`Inexact = Union{AbstractFloat, ...}`\n
The `Inexact` number type union, which includes the following types:\n
    - `AbstractFloat`;
    - `IntervalArithmetic.AbstractInterval{𝗧} where 𝗧<:AbstractFloat}`.
"""
Inexact = Union{AbstractFloat,
                IntervalArithmetic.AbstractInterval{𝗧} where 𝗧<:AbstractFloat}

export Inexact


#----------------------------------------------------------------------------------------------#
#                                  engineConcept{𝗧<:Inexact}                                   #
#----------------------------------------------------------------------------------------------#

"""
`struct engineConcept{𝗧<:Inexact}`\n
Engine proportion parameters structure.
"""
struct engineConcept{𝗧<:Inexact}
    rSD::𝗧
    rLR::𝗧
    # Inner constructors
    engineConcept(x::engineConcept{𝗧}) where 𝗧 = new{𝗧}(x.rSD, x.rLR)
    engineConcept(rsd::𝗧, rlr::𝗧) where 𝗧<:Inexact = new{𝗧}(rsd, rlr)
    engineConcept(rsd::𝗦, rlr::𝗧) where {𝗦<:Inexact, 𝗧<:Inexact} = begin
        engineConcept(promote(rsd, rlr)...)
    end
end

# Outer constructors
(::Type{engineConcept{𝗧}})(s::engineConcept{𝗦}) where {𝗦, 𝗧} = begin
    engineConcept(𝗧(s.rSD), 𝗧(s.rLR))
end

# Methods
rSD(x::engineConcept{𝗧}) where 𝗧 = x.rSD
rDS(x::engineConcept{𝗧}) where 𝗧 = one(𝗧) / x.rSD
rLR(x::engineConcept{𝗧}) where 𝗧 = x.rLR
rRL(x::engineConcept{𝗧}) where 𝗧 = one(𝗧) / x.rLR

# Conversion Methods: all --> D
S2D(x::engineConcept{𝗧}, S::Unitful.Length{𝗧}) where 𝗧 = S * rDS(x)
S2D(x::engineConcept{𝗧}, S::𝗧) where 𝗧 = S * rDS(x) * Unitful.m
R2D(x::engineConcept{𝗧}, R::Unitful.Length{𝗧}) where 𝗧 = 2R * rDS(x)
R2D(x::engineConcept{𝗧}, R::𝗧) where 𝗧 = 2R * rDS(x) * Unitful.m
L2D(x::engineConcept{𝗧}, L::Unitful.Length{𝗧}) where 𝗧 = 2L * rRL(x) * rDS(x)
L2D(x::engineConcept{𝗧}, L::𝗧) where 𝗧 = 2L * rRL(x) * rDS(x) * Unitful.m

# Conversion Methods: D --> all
D2S(x::engineConcept{𝗧}, D::Unitful.Length{𝗧}) where 𝗧 = D * rSD(x)
D2S(x::engineConcept{𝗧}, D::𝗧) where 𝗧 = D * rSD(x) * Unitful.m
D2R(x::engineConcept{𝗧}, D::Unitful.Length{𝗧}) where 𝗧 = D/2 * rSD(x)
D2R(x::engineConcept{𝗧}, D::𝗧) where 𝗧 = D/2 * rSD(x) * Unitful.m
D2L(x::engineConcept{𝗧}, D::Unitful.Length{𝗧}) where 𝗧 = D/2 * rLR(x) * rSD(x)
D2L(x::engineConcept{𝗧}, D::𝗧) where 𝗧 = D/2 * rLR(x) * rSD(x) * Unitful.m


#----------------------------------------------------------------------------------------------#
#                                 struct crankRod{𝗧<:Inexact}                                  #
#----------------------------------------------------------------------------------------------#

struct crankRod{𝗧<:Inexact}
    ec::engineConcept{𝗧}
    D::Unitful.Length{𝗧}
    # Inner constructors
end


#----------------------------------------------------------------------------------------------#
#                                  struct engine{𝗧<:Inexact}                                   #
#----------------------------------------------------------------------------------------------#

struct engine{𝗧<:Inexact}
    id::AbstractString
    z::Integer
end

