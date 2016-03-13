#EasyPlotMPL demonstration 1: Render sample EasyPlot plots
#-------------------------------------------------------------------------------

using EasyPlot
using EasyPlotMPL

#==Constants
===============================================================================#
#pdisp = EasyPlotMPL.PlotDisplay()
pdisp = EasyPlotMPL.PlotDisplay(:tk)


#==Render sample EasyPlot plots
===============================================================================#
plot = evalfile(EasyPlot.sampleplotfile(1));
	display(pdisp, plot)

if false
#	backendlist = [:tk, :gtk3, :gtk, :qt, :wx]
	backendlist = [:tk, :gtk, :qt, :wx]
	for backend in backendlist
		pdisp = EasyPlotMPL.PlotDisplay(backend)
		plot.title = "Backend: $backend"
		display(pdisp, plot)
	end
end

#Last line
