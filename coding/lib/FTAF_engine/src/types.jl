#==============================================================================================#
#                                            Types                                             #
#==============================================================================================#

"""
`Inexact = Union{AbstractFloat, ...}`\n
The `Inexact` number type union, which includes the following types:\n
    - `AbstractFloat`;
    - `AbstractInterval{𝝘} where 𝝘<:AbstractFloat}`.
"""
Inexact = Union{AbstractFloat,
                AbstractInterval{𝝘} where 𝝘<:AbstractFloat}

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

# Fallback methods
rSD(x::pCR{𝗧}) where 𝗧 = rSD(x.ϵ)   # fallback
rDS(x::pCR{𝗧}) where 𝗧 = rDS(x.ϵ)   # fallback
rLR(x::pCR{𝗧}) where 𝗧 = rLR(x.ϵ)   # fallback
rRL(x::pCR{𝗧}) where 𝗧 = rRL(x.ϵ)   # fallback

# Methods
Vdu(x::pCR{𝗧}) where 𝗧 = 𝗧(pi/4) * D(x)^3 * rSD(x)
D(x::pCR{𝗧})   where 𝗧 = x.D
S(x::pCR{𝗧})   where 𝗧 = D(x) * rSD(x)
R(x::pCR{𝗧})   where 𝗧 = D(x) * rSD(x) / 𝗧(2)
L(x::pCR{𝗧})   where 𝗧 = D(x) * rSD(x) * rLR(x) / 𝗧(2)

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
    id::AbstractString                      # Name / IDentifier
    z::Integer                              # Cylinder count
    r::𝗧                                    # Compression ratio
    pcr::pCR{𝗧}                             # Piston-Crank-Rod structure
    θ::Quantity{𝗧,NoDims,U} where {𝗧,U}     # Ignition angle, rad
    # Internal constructors
    engine(eng::engine{𝗧}) where 𝗧 = new{𝗧}(eng.id, eng.z, eng.r, eng.pcr, eng.θ)
    engine(_i::AbstractString, _z::Integer, _r::𝗧, _p::pCR{𝗧},
           _θ::Quantity{𝗧,NoDims,U}) where 𝗧<:Inexact where U = begin
        new{𝗧}(_i, _z, _r, _p, uconvert(Unitful.rad, _θ))
    end
    engine(_i::AbstractString, _z::Integer, _r::𝗥, _p::pCR{𝗦},
           _θ::Quantity{𝗧,NoDims,U}) where {𝗥<:Inexact, 𝗦<:Inexact, 𝗧<:Inexact, U} = begin
        𝗫 = promote_type(𝗥, 𝗦, 𝗧)
        new{𝗫}(_i, _z, 𝗫(_r), pCR{𝗫}(_p), 𝗫(uconvert(Unitful.rad, _θ).val) * Unitful.rad)
    end
end

export engine


# Outer constructors
(::Type{engine{𝗧}})(s::engine{𝗦}) where {𝗦, 𝗧} = begin
    engine(s.id, s.z, 𝗧(s.r), pCR{𝗧}(s.pcr), 𝗧(s.θ.val) * Unitful.rad)
end

# Double fallback methods
rSD(x::engine{𝗧}) where 𝗧 = rSD(x.pcr)  # fallback
rDS(x::engine{𝗧}) where 𝗧 = rDS(x.pcr)  # fallback
rLR(x::engine{𝗧}) where 𝗧 = rLR(x.pcr)  # fallback
rRL(x::engine{𝗧}) where 𝗧 = rRL(x.pcr)  # fallback

# Single fallback methods
Vdu(x::engine{𝗧}) where 𝗧 = Vdu(x.pcr)  # fallback
D(x::engine{𝗧})   where 𝗧 = D(x.pcr)    # fallback
S(x::engine{𝗧})   where 𝗧 = S(x.pcr)    # fallback
R(x::engine{𝗧})   where 𝗧 = R(x.pcr)    # fallback
L(x::engine{𝗧})   where 𝗧 = L(x.pcr)    # fallback

# Raw data methods
id(x::engine{𝗧})  where 𝗧 = x.id
z(x::engine{𝗧})   where 𝗧 = x.z
r(x::engine{𝗧})   where 𝗧 = x.r
pCR(x::engine{𝗧}) where 𝗧 = x.pcr
θ(x::engine{𝗧})   where 𝗧 = x.θ

# Methods
Vd(x::engine{𝗧})    where 𝗧 = Vdu(x) * z(x)
VTDC(x::engine{𝗧})  where 𝗧 = Vdu(x) / (r(x) - one(𝗧))
VBDC(x::engine{𝗧})  where 𝗧 = Vdu(x) + VTDC(x)

# IO Methods
save(x::engine{𝗧}, fname::AbstractString) where 𝗧 = serialize(fname, x)
save(fname::AbstractString, x::engine{𝗧}) where 𝗧 = serialize(fname, x)
load(fname::AbstractString) where 𝗧 = deserialize(fname)


#----------------------------------------------------------------------------------------------#
#                                    struct eST{𝗧<:Inexact}                                    #
#----------------------------------------------------------------------------------------------#

"""
`struct eST{𝗧<:Inexact}`\n
Engine operating state and combustion timing structure.
"""
struct eST{𝗧<:Inexact}
    α::Quantity{𝗧,NoDims,U} where {𝗧,U}     # Angular position with respect to TDS, rad
    ω::Unitful.Frequency{𝗧} where 𝗧         # Angular velocity, rad/s
    Δtc::Unitful.Time{𝗧} where 𝗧            # Combustion duration, s
    # Inner constructors
    eST(x::eST{𝗧}) where 𝗧 = new{𝗧}(x.α, x.ω, x.Δtc)
    eST(alpha::Quantity{𝗧,NoDims,U},
        omega::Unitful.Frequency{𝗧},
        deltc::Unitful.Time{𝗧}) where 𝗧<:Inexact where U = begin
        new{𝗧}(uconvert(u"rad"  , alpha),
               uconvert(u"rad/s", omega),
               uconvert(u"s"    , deltc))
    end
    # TODO: All mixed ...
end

# TODO: outer constructor(s)...

# TODO: methods...


