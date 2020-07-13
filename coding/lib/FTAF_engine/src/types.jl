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
#                                       eMR{𝗧<:Inexact}                                        #
#----------------------------------------------------------------------------------------------#

"""
`struct eMR{𝗧<:Inexact}`\n
Engine Mechanical Ratios structure.
"""
struct eMR{𝗧<:Inexact}
    rSD::𝗧
    rLR::𝗧
    # Inner constructors
    eMR(x::eMR{𝗧}) where 𝗧 = new{𝗧}(x.rSD, x.rLR)
    eMR(rsd::𝗧, rlr::𝗧) where 𝗧<:Inexact = new{𝗧}(rsd, rlr)
    eMR(rsd::𝗦, rlr::𝗧) where {𝗦<:Inexact, 𝗧<:Inexact} = begin
        eMR(promote(rsd, rlr)...)
    end
end

# Outer constructors
(::Type{eMR{𝗧}})(s::eMR{𝗦}) where {𝗦, 𝗧} = begin
    eMR(𝗧(s.rSD), 𝗧(s.rLR))
end

# Methods
rSD(x::eMR{𝗧}) where 𝗧 = x.rSD
rDS(x::eMR{𝗧}) where 𝗧 = one(𝗧) / x.rSD
rLR(x::eMR{𝗧}) where 𝗧 = x.rLR
rRL(x::eMR{𝗧}) where 𝗧 = one(𝗧) / x.rLR

# Conversion Methods: all --> D
S2D(x::eMR{𝗧}, S::Unitful.Length{𝗧}) where 𝗧 = S * rDS(x)
S2D(x::eMR{𝗧}, S::𝗧) where 𝗧 = S * rDS(x) * Unitful.m
R2D(x::eMR{𝗧}, R::Unitful.Length{𝗧}) where 𝗧 = 2R * rDS(x)
R2D(x::eMR{𝗧}, R::𝗧) where 𝗧 = 2R * rDS(x) * Unitful.m
L2D(x::eMR{𝗧}, L::Unitful.Length{𝗧}) where 𝗧 = 2L * rRL(x) * rDS(x)
L2D(x::eMR{𝗧}, L::𝗧) where 𝗧 = 2L * rRL(x) * rDS(x) * Unitful.m

# Conversion Methods: D --> all
D2S(x::eMR{𝗧}, D::Unitful.Length{𝗧}) where 𝗧 = D * rSD(x)
D2S(x::eMR{𝗧}, D::𝗧) where 𝗧 = D * rSD(x) * Unitful.m
D2R(x::eMR{𝗧}, D::Unitful.Length{𝗧}) where 𝗧 = D/2 * rSD(x)
D2R(x::eMR{𝗧}, D::𝗧) where 𝗧 = D/2 * rSD(x) * Unitful.m
D2L(x::eMR{𝗧}, D::Unitful.Length{𝗧}) where 𝗧 = D/2 * rLR(x) * rSD(x)
D2L(x::eMR{𝗧}, D::𝗧) where 𝗧 = D/2 * rLR(x) * rSD(x) * Unitful.m


#----------------------------------------------------------------------------------------------#
#                                       pCR{𝗧<:Inexact}                                        #
#----------------------------------------------------------------------------------------------#

"""
`struct pCR{𝗧<:Inexact}`\n
Piston-Crank-Rod mechanism structure.
"""
struct pCR{𝗧<:Inexact}
    ϵ::eMR{𝗧}               # engine mechanical ratios
    D::Unitful.Length{𝗧}    # Diameter, in m
    # Inner constructors
    pCR(pcr::pCR{𝗧}) where 𝗧 = new{𝗧}(pcr.ϵ, pcr.D)
    pCR(emr::eMR{𝗧}, dia::Unitful.Length{𝗧}) where 𝗧 = begin
        new{𝗧}(emr, Unitful.uconvert(Unitful.m, dia))
    end
    pCR(emr::eMR{𝗦}, dia::Unitful.Length{𝗧}) where {𝗦<:Inexact, 𝗧<:Inexact} = begin
        𝗫 = promote_type(𝗦, 𝗧)
        pCR(eMR{𝗫}(emr), 𝗫(Unitful.uconvert(Unitful.m, dia).val) * Unitful.m)
    end
end


#----------------------------------------------------------------------------------------------#
#                                  struct engine{𝗧<:Inexact}                                   #
#----------------------------------------------------------------------------------------------#

struct engine{𝗧<:Inexact}
    id::AbstractString
    z::Integer
end

