#EasyPlotMPL demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using EasyPlotMPL
using EasyPlot

#==Constants
===============================================================================#


#==Render sample EasyPlot plots
===============================================================================#
plot = evalfile(EasyPlot.sampleplotfile(1));
	display(Backend{:MPL}, plot)

#Last line
