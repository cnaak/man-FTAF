#==============================================================================================#
#                                            Types                                             #
#==============================================================================================#

"""
`Inexact = Union{AbstractFloat}`\n
The `Inexact` number type union.
"""
Inexact = Union{AbstractFloat}

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
    engineConcept(x::engineConcept{𝗫}) where 𝗫 = new{𝗫}(x.rSD, x.rLR)
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



## struct engine{𝗧<:Inexact}
##     id::AbstractString
##     
## end

