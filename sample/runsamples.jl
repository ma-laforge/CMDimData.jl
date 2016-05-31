#EasyPlotInspect demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using EasyPlotInspect
using EasyPlot
using FileIO2


#==Constants
===============================================================================#
pdisp = EasyPlotInspect.PlotDisplay()


#==Render sample EasyPlot plots
===============================================================================#
plot = evalfile(EasyPlot.sampleplotfile(1));
	display(pdisp, plot)

#Not yet supported (can only save single plots):
#	EasyPlot._write(File(:png, "image.png"), plot, pdisp)
#	EasyPlot._write(File(:svg, "image.svg"), plot, pdisp)

:DONE
