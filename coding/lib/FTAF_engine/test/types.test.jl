#----------------------------------------------------------------------------------------------#
#                                        types.test.jl                                         #
#----------------------------------------------------------------------------------------------#

@testset "types.test.jl: Inexact                                                    " begin
    @test Float16  <: Inexact
    @test Float32  <: Inexact
    @test Float64  <: Inexact
    @test BigFloat <: Inexact
end

