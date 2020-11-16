#Run sample code
#-------------------------------------------------------------------------------

module CMDimData_SampleGenerator

using CMDimData
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotMPL


#==Constants
===============================================================================#
const TEST_BACKENDS = true
backendtestlist = [:tk, :gtk3, :gtk, :qt, :wx]
demolist = EasyPlot.demofilelist()


pdisp = EasyPlotMPL.PlotDisplay()
#pdisp = EasyPlotMPL.PlotDisplay(:tk)


#==Helper functions
===============================================================================#
printsep(title) = println("\n", title, "\n", repeat("-", 80))


#==Write an EasyPlotMPL plot to file.
===============================================================================#
plot = evalfile(demolist[1])

pdisp_nogui = EasyPlotMPL.PlotDisplay(guimode=false)
	EasyPlot.write_png("image.png", plot, pdisp_nogui)
	EasyPlot.write_svg("image.svg", plot, pdisp_nogui)


#==Test different backends
===============================================================================#
if TEST_BACKENDS
	plot = evalfile(demolist[1])
	for backend in backendtestlist
		pdisp = EasyPlotMPL.PlotDisplay(backend)
		plot.title = "Backend: $backend"

		try
			display(pdisp, plot)
		catch e
			@warn e.msg
		end
	end
end


#==Render sample EasyPlot plots
===============================================================================#
for demofile in demolist
	fileshort = basename(demofile)
	printsep("Executing $fileshort...")
	plot = evalfile(demofile)
	display(pdisp, plot)
end

end
:SampleCode_Executed
