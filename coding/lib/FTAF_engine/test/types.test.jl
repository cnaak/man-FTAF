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
                @test eng.S2D(_emr, eng.D2S(_emr, 𝔻)) ≈ 𝕕 atol = eps(𝕕)
                @test eng.R2D(_emr, eng.D2R(_emr, 𝔻)) ≈ 𝕕 atol = eps(𝕕)
                @test eng.L2D(_emr, eng.D2L(_emr, 𝔻)) ≈ 𝕕 atol = eps(𝕕)
            end
        end
    end
end

@testset "types.test.jl: pCR - Piston-Crank-Rod mechanism                           " begin
    RSD = BigFloat("1.1")
    RLR = BigFloat("3.1")
    DIA = BigFloat("0.1")
    VDU = BigFloat("0.26")
    for 𝕋 in (Float16, Float32, Float64, BigFloat)
        𝕖 = eMR(𝕋(RSD), 𝕋(RLR))
        for 𝕊 in (Float16, Float32, Float64, BigFloat)
            𝕕 = 𝕊(DIA) * eng.u"m"
            _pcr = pCR(𝕖, 𝕕)
            ℙ = promote_type(𝕋, 𝕊)
            @test _pcr isa pCR{ℙ}
            @test pCR{𝕋}(_pcr) isa pCR{𝕋}
            @test pCR{𝕊}(_pcr) isa pCR{𝕊}
            #--- methods
            𝕧 = ℙ(π) * _pcr.D^3 * 𝕋(RSD) / 4    # RSD calculated with 𝕋 precision at best
            𝕤, 𝕣, 𝕝 = eng.D2S(_pcr.ϵ, _pcr.D), eng.D2R(_pcr.ϵ, _pcr.D), eng.D2L(_pcr.ϵ, _pcr.D)
            @test eng.Vdu(_pcr) ≈ 𝕧 atol = eps(𝕧)
            @test eng.D(_pcr)   ≈ 𝕕 atol = eps(𝕕)
            @test eng.S(_pcr)   ≈ 𝕤 atol = eps(𝕤)
            @test eng.R(_pcr)   ≈ 𝕣 atol = eps(𝕣)
            @test eng.L(_pcr)   ≈ 𝕝 atol = eps(𝕝)
            #--- reverse constructor
            𝕧 = ℙ(𝕊(VDU)) * eng.u"l"   # Vdu in liters
            𝕖 = eMR{ℙ}(𝕖)
            _PCR = pCR(𝕖, 𝕧)
            @test _PCR isa pCR{ℙ}
            vS = 𝕊(eng.uconvert(eng.u"m^3", 𝕊(VDU) * eng.u"l"))
            vT = 𝕋(eng.uconvert(eng.u"m^3", 𝕋(VDU) * eng.u"l"))
            @test eng.Vdu(_PCR) ≈ 𝕧 atol = max(eps(vS), eps(vT)) * 3
        end
    end
end

