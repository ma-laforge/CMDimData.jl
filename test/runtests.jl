using Test, CMDimData


function printsep(title)
	println("\n", title, "\n", repeat("-", 80))
end

function show_testset_description()
	@info Test.get_testset().description
end

@testset "CMDimData tests" begin
	testfiles = ["EasyPlot.jl", "EasyData.jl"]

	for testfile in testfiles
		include(testfile)
	end

end #testset

:Test_Complete
