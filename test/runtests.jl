#Test code
#-------------------------------------------------------------------------------

using MDDatasets
using FileIO2
using EasyPlot
using EasyData

#No real test code yet... just run demos:

function printsep()
	const separator = "\n-----------------------------"
	println(separator)
end

for i in 1:1
	filepath = "./sampleplot$i.hdf5"
	printsep()
		@show p=evalfile(EasyPlot.sampleplotfile(1));
		save(p, filepath)
	println("\n\nReloading...")
		@show p=load(File{EDH5Fmt}(filepath));
end

for i in 1:1
	printsep()
	include("../sample/demo$i.jl")
end


:Test_Complete
