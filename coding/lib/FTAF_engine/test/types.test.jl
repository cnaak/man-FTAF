#----------------------------------------------------------------------------------------------#
#                                        types.test.jl                                         #
#----------------------------------------------------------------------------------------------#

@testset "types.test.jl: Inexact Type Union.                                        " begin
    for T in (Float16, Float32, Float64, BigFloat)
        @test T <: Inexact
        @test eng.IntervalArithmetic.AbstractInterval{T} <: Inexact
    end
end

@testset "types.test.jl: eMR - Engine Mechanical Ratios.                            " begin
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

@testset "types.test.jl: pCR - Piston-Crank-Rod mechanism.                          " begin
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
            𝔽 = Float64             # Hardcoded uconvert precision
            vS = 𝕊(eng.uconvert(eng.u"m^3", 𝕊(VDU) * eng.u"l"))
            vT = 𝕋(eng.uconvert(eng.u"m^3", 𝕋(VDU) * eng.u"l"))
            vF = 𝔽(eng.uconvert(eng.u"m^3", 𝔽(VDU) * eng.u"l"))
            @test eng.Vdu(_PCR) ≈ ℙ(vS) atol = max(eps(vS), eps(vT), eps(vF)) * 3
        end
    end
end

@testset "types.test.jl: engine - Simple internal combustion engine structure.      " begin
    RSD = BigFloat("1.1")
    RLR = BigFloat("3.1")
    DIA = BigFloat("0.1")
    VDU = BigFloat("0.26")
    RAT = BigFloat("12.6")
    THE = BigFloat("-50.1") * BigFloat(π) / 180
    for 𝕋 in (Float16, Float32, Float64, BigFloat)
        𝕣 = 𝕋(RAT)
        for 𝕊 in (Float16, Float32, Float64, BigFloat)
            𝕡 = pCR(eMR(𝕊(RSD), 𝕊(RLR)), 𝕊(VDU) * eng.u"l")
            for ℝ in (Float16, Float32, Float64, BigFloat)
                𝕠 = ℝ(THE) * eng.u"rad"
                𝔼 = engine("Test", 4, 𝕣, 𝕡, 𝕠)
                𝕏 = promote_type(ℝ, 𝕊, 𝕋)
                # Inner constructors
                @test 𝔼 isa engine{𝕏}
                # Outer constructors
                @test engine{ℝ}(𝔼) isa engine{ℝ}
                @test engine{𝕊}(𝔼) isa engine{𝕊}
                @test engine{𝕋}(𝔼) isa engine{𝕋}
                # Raw data methods
                @test eng.id(𝔼)  == "Test"
                @test eng.z(𝔼)   == 4
                @test eng.r(𝔼)   == 𝕏(𝕣)
                tmpa, tmpb = eng.pCR(𝔼), pCR{𝕏}(𝕡)
                # Avoid ===(x, y) from generic ==(x, y) which gives some false negatives
                @test (tmpa.ϵ.rSD, tmpa.ϵ.rLR, tmpa.D) == (tmpb.ϵ.rSD, tmpb.ϵ.rLR, tmpb.D)
                @test eng.θ(𝔼)   == 𝕏(𝕠)
                # Methods
                𝕍𝕕𝕦 = eng.Vdu(eng.pCR(𝔼))
                𝕍𝕕 = 𝕍𝕕𝕦 * eng.z(𝔼)
                𝕍𝕋 = 𝕍𝕕𝕦 / (eng.r(𝔼) - one(𝕏))
                𝕍𝔹 = 𝕍𝕕𝕦 + 𝕍𝕋
                @test eng.Vd(𝔼) ≈ 𝕍𝕕 atol = eps(𝕍𝕕)
                @test eng.VTDC(𝔼) ≈ 𝕍𝕋 atol = eps(𝕍𝕋)
                @test eng.VBDC(𝔼) ≈ 𝕍𝔹 atol = eps(𝕍𝔹)
            end
        end
        𝕡 = pCR(eMR(𝕋(RSD), 𝕋(RLR)), 𝕋(VDU) * eng.u"l")
        𝕠 = 𝕋(THE) * eng.u"rad"
        𝔼 = engine("Test", 4, 𝕣, 𝕡, 𝕠)
        eng.save(𝔼, "test.engine.$𝕋.jds")
        𝕖 = eng.load("test.engine.$𝕋.jds")
        if 𝕋 == BigFloat
            @test 𝔼.id          == 𝕖.id
            @test 𝔼.z           == 𝕖.z
            @test 𝔼.r           == 𝕖.r
            @test 𝔼.θ           == 𝕖.θ
            @test 𝔼.pcr.D       == 𝕖.pcr.D
            @test 𝔼.pcr.ϵ.rSD   == 𝕖.pcr.ϵ.rSD
            @test 𝔼.pcr.ϵ.rLR   == 𝕖.pcr.ϵ.rLR
        else
            @test hash(𝔼) == hash(𝕖)
        end
    end
end

