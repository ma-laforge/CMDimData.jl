#EasyPlotQwt demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using FileIO2
using EasyPlot
using EasyPlotQwt
using EasyData


#==Constants
===============================================================================#


#==Render sample EasyPlot plots
===============================================================================#
file(i::Int) = File(:edh5, "./sampleplotfile1.hdf5")

plot = evalfile(EasyPlot.sampleplotfile(1));
	display(:Qwt, plot)
	write(file(1), plot)
plot2=read(file(1), EasyPlot.Plot);
	plot2.title = "Compare Loaded File"
	display(:Qwt, plot2)

#Last line
