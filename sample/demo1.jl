#EasyPlotPlots demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using EasyPlot
using EasyPlotPlots
using EasyData


#==Constants
===============================================================================#


#==Input Data
===============================================================================#
bknd = :Plots_MPL
#bknd = :Plots_Gadfly
#bknd = :Plots_Winston
#bknd = :Plots_Bokeh
#bknd = :Plots_Qwt
#bknd = :Plots_GR


#==Render sample EasyPlot plots
===============================================================================#
plot = evalfile(EasyPlot.sampleplotfile(1));
	display(bknd, plot)

#Last line
