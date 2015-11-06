#Test code
#-------------------------------------------------------------------------------

using MDDatasets
using FileIO2
using EasyPlot
using EasySave

#No real test code yet... just run demos:

function printsep()
	const separator = "\n-----------------------------"
	println(separator)
end

for i in 1:1
	printsep()
		@show p=evalfile(EasyPlot.sampleplotfile(1));
		save(p, "./sampleplot$i.hdf5")
	println("\n\nReloading...")
		@show p=load(File{EPH5Fmt}("./sampleplot$i.hdf5"));
end

:Test_Complete
