#Test EasyData's read/write capabilities using sample/ plots
#-------------------------------------------------------------------------------
#=
Look for EasyData._write() & EasyData._read() near end of file.
=#


module CMDimData_SampleUsage

using CMDimData
using CMDimData.EasyPlot
using CMDimData.EasyData
CMDimData.@includepkg EasyPlotInspect


#==Constants
===============================================================================#
demolist = EasyPlot.demofilelist()


#==Helper functions
===============================================================================#
printsep(label, sep="-") = println("\n", label, "\n", repeat(sep, 80))
printheader(label) = printsep(label, "=")


#==Main Code
===============================================================================#
pdisp = EasyPlot.GUIDisplay(:InspectDR)
for filepath in demolist
	corename = splitext(basename(filepath))[1]
	filename = "sample_$corename.hdf5"
	printsep("Executing $filepath...")
	pcoll = evalfile(filepath)
	display(pdisp, pcoll)

	#EasyData portion:
	@info("Writing $filename...")
	EasyData.writeplot(filename, pcoll)
	@info("Reading back $filename...")
	plot2 = EasyData.readplot(filename)
	plot2.title = "Compare Results: " * pcoll.title
	display(pdisp, plot2)
end

end
:SampleCode_Executed
