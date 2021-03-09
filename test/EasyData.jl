using CMDimData.MDDatasets
using CMDimData.EasyPlot
using CMDimData.EasyData

@testset "EasyData tests" begin #Scope for test data
	show_testset_description()

	function _isequal(d1::DataF1, d2::DataF1)
		Δ = abs(d2 - d1)
		return maximum(Δ) == 0
	end

@testset "Write/Read DataF1 comparison" begin
	show_testset_description()
	tmpfilepath = "test_datafile.hdf5"

	x = DataF1(0:.1:2π)
	s_sin = sin(x); s_cos = cos(x)

	EasyData.openwriter(tmpfilepath) do w
		write(w, s_cos, "cos")
		write(w, s_sin, "sin")
	end

	local d_sin, d_cos
	EasyData.openreader(tmpfilepath) do r
		d_sin = EasyData.readdata(r, "sin")
		d_cos = EasyData.readdata(r, "cos")
	end
	@test _isequal(s_sin, d_sin)
	@test _isequal(s_cos, d_cos)
end

@testset "Write/Read demo plot comparison" begin
	show_testset_description()
	filelist = EasyPlot.demofilelist()
	@warn("TODO: Check correspondance of all plot elements!!!")

	for filepath in filelist
		@info("Evaluating plots in $filepath...")
		fname = splitext(basename(filepath))[1]
		tmpfilepath = "test_$fname.hdf5"
		src = evalfile(filepath)
		EasyData.writeplot(tmpfilepath, src)
		dest = EasyData.readplot(tmpfilepath)

		@test src.title == dest.title
	end
end

end
