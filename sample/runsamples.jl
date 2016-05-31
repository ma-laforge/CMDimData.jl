#Run sample code
#-------------------------------------------------------------------------------

using EasyPlot
using EasyPlotMPL
using FileIO2


#==Constants
===============================================================================#
pdisp = EasyPlotMPL.PlotDisplay()
#pdisp = EasyPlotMPL.PlotDisplay(:tk)
demolist = EasyPlot.demofilelist()


#==Write an EasyPlotMPL plot to file.
===============================================================================#
plot = evalfile(demolist[1])

pdisp_nogui = EasyPlotMPL.PlotDisplay(guimode=false)
	EasyPlot._write(File(:png, "image.png"), plot, pdisp_nogui)
	EasyPlot._write(File(:svg, "image.svg"), plot, pdisp_nogui)


#==Render sample EasyPlot plots
===============================================================================#
for demofile in demolist
	fileshort = basename(demofile)
	sepline = "---------------------------------------------------------------------"
	println("\nExecuting $fileshort...")
	println(sepline)
	plot = evalfile(demofile)
	display(pdisp, plot)
end


#==Test different backends
===============================================================================#
if false
#	backendlist = [:tk, :gtk3, :gtk, :qt, :wx]
	backendlist = [:tk, :gtk, :qt, :wx]
	for backend in backendlist
		pdisp = EasyPlotMPL.PlotDisplay(backend)
		plot.title = "Backend: $backend"
		display(pdisp, plot)
	end
end

:SampleCode_Executed
