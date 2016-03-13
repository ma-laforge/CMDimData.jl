#EasyPlotQwt demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using FileIO2
using EasyPlot
using EasyPlotQwt


#==Constants
===============================================================================#
pdisp = EasyPlotQwt.PlotDisplay()


#==Render sample EasyPlot plots
===============================================================================#
plot = evalfile(EasyPlot.sampleplotfile(1));
	display(pdisp, plot)

#Last line
