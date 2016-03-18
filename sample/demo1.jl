#EasyPlotGrace demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using EasyPlotGrace
using EasyPlot
using FileIO2


#==Constants
===============================================================================#
template = GracePlot.template("smallplot_mono")
plotdefaults = GracePlot.defaults(linewidth=2.5)
pdisp = EasyPlotGrace.PlotDisplay()
#pdisp = EasyPlotGrace.PlotDisplay(template=template)
#pdisp = EasyPlotGrace.PlotDisplay(plotdefaults)


#==Render sample EasyPlot plots
===============================================================================#
plot = evalfile(EasyPlot.sampleplotfile(1));
	display(pdisp, plot)

pdisp = EasyPlotGrace.PlotDisplay(guimode=false)
	EasyPlot._write(File(:png, "image.png"), plot, pdisp)
#	EasyPlot._write(File(:svg, "image.svg"), plot, pdisp)
#Last line
