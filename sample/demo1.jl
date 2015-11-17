#EasyPlotGrace demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using EasyPlotGrace
using EasyPlot


#==Constants
===============================================================================#
const template=GracePlot.template("smallplot_mono")

#==Render sample EasyPlot plots
===============================================================================#
plot = evalfile(EasyPlot.sampleplotfile(1));
	display(:Grace, plot)
#	display(:Grace, plot, template=template)

#Last line
