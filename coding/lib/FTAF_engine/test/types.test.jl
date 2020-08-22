#----------------------------------------------------------------------------------------------#
#                                        types.test.jl                                         #
#----------------------------------------------------------------------------------------------#

@testset "types.test.jl: Inexact                                                    " begin
    for T in (Float16, Float32, Float64, BigFloat)
        @test T <: Inexact
        @test eng.IntervalArithmetic.AbstractInterval{T} <: Inexact
    end
end

@testset "types.test.jl: eMR - Engine Mechanical Ratios                             " begin
    RSD = BigFloat("1.1")
    RLR = BigFloat("3.1")
    for 𝕋 in (Float16, Float32, Float64, BigFloat)
        _rsd = 𝕋(RSD)
        for 𝕊 in (Float16, Float32, Float64, BigFloat)
            _rlr = 𝕊(RLR)
            _emr = eMR(_rsd, _rlr)
            ℙ = promote_type(𝕋, 𝕊)
            @test _emr isa eMR{ℙ}
            @test eMR{𝕋}(_emr) isa eMR{𝕋}
            @test eMR{𝕊}(_emr) isa eMR{𝕊}
            @test eng.rSD(_emr) == ℙ(_rsd)
            @test eng.rDS(_emr) == one(ℙ) / ℙ(_rsd)
            @test eng.rLR(_emr) == ℙ(_rlr)
            @test eng.rRL(_emr) == one(ℙ) / ℙ(_rlr)
        end
    end
end

