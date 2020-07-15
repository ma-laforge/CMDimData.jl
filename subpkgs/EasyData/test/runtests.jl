#Test code
#-------------------------------------------------------------------------------

using MDDatasets
using FileIO2
using EasyPlot
using EasyData

#No real test code yet... just run demos:

function printsep()
	separator = "\n-----------------------------" #WANTCONST
	println(separator)
end

x = DataF1(1:100)
data = sin(x)
filepath = "./sampledata.hdf5"
h5path = "my/sub/path"
EasyData._write(filepath, h5path, data)
dread = EasyData._read(filepath, h5path, DataMD)
@show data - dread

#throw(:ERR)
let filepath #HIDEWARN_0.7
for i in 1:1
	#Test high-level "File()" read/write interface:
	filepath = "./sampleplot$i.hdf5"
	file = File(:edh5, filepath)
	printsep()
		@show p=evalfile(EasyPlot.sampleplotfile(i));
		write(file, p)
	println("\n\nReloading...")
		@show p=read(file, EasyPlot.Plot);
end
end
#throw(:ERR)

include("../sample/runsamples.jl")


:Test_Complete
