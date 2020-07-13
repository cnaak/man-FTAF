#==============================================================================================#
#                                            Types                                             #
#==============================================================================================#

"""
`Inexact = Union{AbstractFloat, ...}`\n
The `Inexact` number type union, which includes the following types:\n
    - `AbstractFloat`;
    - `AbstractInterval{𝗧} where 𝗧<:AbstractFloat}`.
"""
Inexact = Union{AbstractFloat,
                AbstractInterval{𝗧} where 𝗧<:AbstractFloat}

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

export eMR


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

export S2D, R2D, L2D

# Conversion Methods: D --> all
D2S(x::eMR{𝗧}, D::Unitful.Length{𝗧}) where 𝗧 = D * rSD(x)
D2S(x::eMR{𝗧}, D::𝗧) where 𝗧 = D * rSD(x) * Unitful.m
D2R(x::eMR{𝗧}, D::Unitful.Length{𝗧}) where 𝗧 = D/2 * rSD(x)
D2R(x::eMR{𝗧}, D::𝗧) where 𝗧 = D/2 * rSD(x) * Unitful.m
D2L(x::eMR{𝗧}, D::Unitful.Length{𝗧}) where 𝗧 = D/2 * rLR(x) * rSD(x)
D2L(x::eMR{𝗧}, D::𝗧) where 𝗧 = D/2 * rLR(x) * rSD(x) * Unitful.m

export D2S, D2R, D2L


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
    pCR(emr::eMR{𝗧}, dia::Unitful.Length{𝗧}) where 𝗧<:Inexact = begin
        new{𝗧}(emr, uconvert(Unitful.m, dia))
    end
    pCR(emr::eMR{𝗦}, dia::Unitful.Length{𝗧}) where {𝗦<:Inexact, 𝗧<:Inexact} = begin
        𝗫 = promote_type(𝗦, 𝗧)
        pCR(eMR{𝗫}(emr), 𝗫(uconvert(Unitful.m, dia).val) * Unitful.m)
    end
end

export pCR


# Outer constructors
(::Type{pCR{𝗧}})(s::pCR{𝗦}) where {𝗦, 𝗧} = begin
    pCR(eMR{𝗧}(s.ϵ), 𝗧(s.D.val) * Unitful.m)
end

# Methods
rSD(x::pCR{𝗧}) where 𝗧 = x.ϵ.rSD
rDS(x::pCR{𝗧}) where 𝗧 = one(𝗧) / x.ϵ.rSD
rLR(x::pCR{𝗧}) where 𝗧 = x.ϵ.rLR
rRL(x::pCR{𝗧}) where 𝗧 = one(𝗧) / x.ϵ.rLR

Vdu(x::pCR{𝗧}) where 𝗧 = 𝗧(pi/4) * x.D^3 * x.ϵ.rSD
D(x::pCR{𝗧})   where 𝗧 = x.D
S(x::pCR{𝗧})   where 𝗧 = x.D * x.ϵ.rSD
R(x::pCR{𝗧})   where 𝗧 = x.D * x.ϵ.rSD / 𝗧(2)
L(x::pCR{𝗧})   where 𝗧 = x.D * x.ϵ.rSD * x.ϵ.rLR / 𝗧(2)

# Reverse constructors
pCR(emr::eMR{𝗧}, vdu::Unitful.Volume{𝗧}) where 𝗧<:Inexact = begin
    dia = cbrt(vdu * 𝗧(4/pi) / emr.rSD)
    pCR(emr, dia)
end


#----------------------------------------------------------------------------------------------#
#                                  struct engine{𝗧<:Inexact}                                   #
#----------------------------------------------------------------------------------------------#

"""
`struct engine{𝗧<:Inexact}`\n
Simple internal combustion engine structure.
"""
struct engine{𝗧<:Inexact}
    id::AbstractString      # Name / IDentifier
    z::Integer              # Cylinder count
    r::𝗧                    # Compression ratio
    pcr::pCR{𝗧}             # Piston-Crank-Rod structure
end

