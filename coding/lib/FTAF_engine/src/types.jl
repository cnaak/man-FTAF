#==============================================================================================#
#                                            Types                                             #
#==============================================================================================#

#----------------------------------------------------------------------------------------------#
#                               engineConcept{𝗧<:AbstractFloat}                                #
#----------------------------------------------------------------------------------------------#

"""
`struct engineConcept{𝗧<:AbstractFloat}`\n
Engine proportion parameters structure.
"""
struct engineConcept{𝗧<:AbstractFloat}
    rSD::𝗧
    rLR::𝗧
    # Inner constructors
    engineConcept(x::engineConcept{𝗫}) where 𝗫 = new{𝗫}(x.rSD, x.rLR)
    engineConcept(rsd::𝗧, rlr::𝗧) where 𝗧<:AbstractFloat = new{𝗧}(rsd, rlr)
    engineConcept(rsd::𝗦, rlr::𝗧) where {𝗦<:AbstractFloat, 𝗧<:AbstractFloat} = begin
        engineConcept(promote(rsd, rlr)...)
    end
end

# Outer constructors
(::Type{engineConcept{𝗧}})(s::engineConcept{𝗦}) where {𝗦, 𝗧} = begin
    engineConcept(𝗧(s.rSD), 𝗧(s.rLR))
end

# Methods



## struct engine{𝗧<:AbstractFloat}
##     id::AbstractString
##     
## end

