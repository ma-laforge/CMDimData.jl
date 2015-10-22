#EasyPlotMPL demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using EasyPlotMPL
using EasyPlot
using FileIO2

#==Constants
===============================================================================#


#==Render sample EasyPlot plots
===============================================================================#
file(i::Int) = File{EPH5Fmt}("./sampleplotfile1.hdf5")

plot = evalfile(EasyPlot.sampleplotfile(1));
	display(Backend{:MPL}, plot)
	save(plot, file(1))
plot2=load(file(1))[1]; #Returns array of plots
	plot2.title = "Compare Loaded File"
	display(Backend{:MPL}, plot2)

#Last line
