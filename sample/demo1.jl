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
file(i::Int) = File{EDH5Fmt}("./sampleplotfile1.hdf5")

plot = evalfile(EasyPlot.sampleplotfile(1));
	display(:MPL, plot)
	save(plot, file(1))
plot2=load(file(1))[1]; #Returns array of plots
	plot2.title = "Compare Loaded File"
	display(:MPL, plot2)

#Last line
