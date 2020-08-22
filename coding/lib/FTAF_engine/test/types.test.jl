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
            #--- methods
            @test eng.rSD(_emr) == ℙ(_rsd)
            @test eng.rDS(_emr) == one(ℙ) / ℙ(_rsd)
            @test eng.rLR(_emr) == ℙ(_rlr)
            @test eng.rRL(_emr) == one(ℙ) / ℙ(_rlr)
            #--- conversions
            for 𝔻 in (one(ℙ), one(ℙ) * eng.u"m")
                𝕕 = one(ℙ) * eng.u"m"
                𝕤 = 𝕕 * ℙ(_rsd)
                𝕣 = 𝕤 / ℙ(2)
                𝕝 = 𝕣 * ℙ(_rlr)
                @test eng.D2S(_emr, 𝔻) == 𝕤
                @test eng.D2R(_emr, 𝔻) == 𝕣
                @test eng.D2L(_emr, 𝔻) == 𝕝
                @test eng.S2D(_emr, 𝕤) == 𝕤 * one(ℙ) / ℙ(_rsd)
                @test eng.R2D(_emr, 𝕣) == 2𝕣 * one(ℙ) / ℙ(_rsd)
                @test eng.L2D(_emr, 𝕝) == 2𝕝 * one(ℙ) / ℙ(_rlr) * one(ℙ) / ℙ(_rsd)
            end
        end
    end
end

