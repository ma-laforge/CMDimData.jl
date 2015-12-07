#EasyPlotMPL demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using FileIO2
using EasyPlot
using EasyPlotMPL
using EasyData

#==Constants
===============================================================================#


#==Render sample EasyPlot plots
===============================================================================#
file(i::Int) = File(:edh5, "./sampleplotfile1.hdf5")

plot = evalfile(EasyPlot.sampleplotfile(1));
	display(:MPL, plot)
	write(file(1), plot)
plot2=read(file(1))[1]; #Returns array of plots
	plot2.title = "Compare Loaded File"
	display(:MPL, plot2)

#Last line
