using CMDimData.MDDatasets
using CMDimData.EasyPlot
CMDimData.@includepkg EasyData

@testset "EasyData tests" begin #Scope for test data

#No real test code yet... just run demos:

x = DataF1(1:100)
data = sin(x)
filepath = "./sampledata.hdf5"
h5path = "my/sub/path"
EasyData._write(filepath, h5path, data)
dread = EasyData._read(filepath, h5path, DataMD)
@show data - dread

filelist = EasyPlot.demofilelist()

#throw(:ERR)
for i in 1:1
	#Test high-level "File()" read/write interface:
	filepath = "./sampleplot$i.hdf5"
	printsep("")
		@show p=evalfile(filelist[i]);
		EasyData._write(filepath, p)
	println("\n\nReloading...")
		@show p=EasyData._read(filepath, EasyPlot.Plot);
end
#throw(:ERR)

end
