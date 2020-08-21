#----------------------------------------------------------------------------------------------#
#                                        types.test.jl                                         #
#----------------------------------------------------------------------------------------------#

@testset "types.test.jl: Inexact                                                    " begin
    for T in (Float16, Float32, Float64, BigFloat)
        @test T <: Inexact
        @test eng..IntervalArithmetic.AbstractInterval{T} <: Inexact
    end
end

