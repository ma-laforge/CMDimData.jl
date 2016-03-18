#EasyPlotPlots demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using EasyPlot
using EasyPlotPlots
using FileIO2


#==Constants
===============================================================================#
renderingtool = :pyplot #Python based
#renderingtool = :gadfly
#renderingtool = :gr
#renderingtool = :pgfplots
#renderingtool = :plotly #Browser based?
#renderingtool = :glvisualize #3D-heavy
#renderingtool = :unicodeplots #Text-based
#pdisp = EasyPlotPlots.PlotDisplay()
pdisp = EasyPlotPlots.PlotDisplay(renderingtool)


#==Render sample EasyPlot plots
===============================================================================#
plot = evalfile(EasyPlot.sampleplotfile(1));
	display(pdisp, plot)
	EasyPlot._write(File(:png, "image.png"), plot, pdisp)
#	EasyPlot._write(File(:svg, "image.svg"), plot, pdisp)
#Last line
