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
		@show p=evalfile(EasyPlot.sampleplotfile(i));
		write(filepath, p)
	println("\n\nReloading...")
		@show p=read(File(:edh5, filepath));
end

for i in 1:3
	file = "../sample/demo$i.jl"
	println("\nExecuting $file...")
	printsep()
	include(file)
end


:Test_Complete
