#Run sample code
#-------------------------------------------------------------------------------

using EasyPlot
using EasyPlotQwt
using FileIO2


#==Constants
===============================================================================#
pdisp = EasyPlotQwt.PlotDisplay()
demolist = EasyPlot.demofilelist()


#==Render sample EasyPlot plots
===============================================================================#
for demofile in demolist
	fileshort = basename(demofile)
	sepline = "---------------------------------------------------------------------"
	println("\nExecuting $fileshort...")
	println(sepline)
	plot = evalfile(demofile)
	display(pdisp, plot)
	#EasyPlot._write(File(:png, "image.png"), plot, pdisp)
end

:SampleCode_Executed
