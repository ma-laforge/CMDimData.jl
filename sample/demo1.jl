#EasyPlotGrace demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using EasyPlotGrace
using EasyPlot


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

#Last line
