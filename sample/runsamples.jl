#Run sample code
#-------------------------------------------------------------------------------

using EasyPlotInspect
using EasyPlot
using FileIO2


#==Constants
===============================================================================#
pdisp = EasyPlotInspect.PlotDisplay()
demolist = EasyPlot.demofilelist()


#==Write an EasyPlotInspect plot to file.
===============================================================================#
plot = evalfile(demolist[1])
	EasyPlot._write(File(:png, "image.png"), plot, pdisp)
	EasyPlot._write(File(:svg, "image.svg"), plot, pdisp)


#==Render sample EasyPlot plots
===============================================================================#
for demofile in demolist
	fileshort = basename(demofile)
	sepline = "---------------------------------------------------------------------"
	println("\nExecuting $fileshort...")
	println(sepline)
	plot = evalfile(demofile)
	display(pdisp, plot)
end

:SampleCode_Executed
