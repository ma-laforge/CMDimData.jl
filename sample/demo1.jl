#EasyPlotGrace demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using EasyPlotGrace
using EasyPlot


#==Constants
===============================================================================#
const engpaper=GracePlot.template("engpaper_mono")


#==Render sample EasyPlot plots
===============================================================================#
plot = evalfile(EasyPlot.sampleplotfile(1));
	#display(Backend{:Grace}, plot, template=engpaper)
	display(Backend{:Grace}, plot)

#Last line
