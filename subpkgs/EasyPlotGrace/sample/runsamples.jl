#Run sample code
#-------------------------------------------------------------------------------

using EasyPlotGrace
using EasyPlot
using FileIO2
import GracePlot


#==Constants
===============================================================================#
template = GracePlot.template("smallplot_mono")
plotdefaults = GracePlot.defaults(linewidth=2.5)
pdisp = EasyPlotGrace.PlotDisplay()
#pdisp = EasyPlotGrace.PlotDisplay(template=template)
#pdisp = EasyPlotGrace.PlotDisplay(plotdefaults)
demolist = EasyPlot.demofilelist()


#==Write an EasyPlotGrace plot to file.
===============================================================================#
plot = evalfile(demolist[1])

pdisp_nogui = EasyPlotGrace.PlotDisplay(guimode=false)
	EasyPlot._write(File(:png, "image.png"), plot, pdisp_nogui)
#	EasyPlot._write(File(:svg, "image.svg"), plot, pdisp_nogui)
#Last line


#==Render sample EasyPlot plots
===============================================================================#
let plot #HIDEWARN_0.7
for demofile in demolist
	fileshort = basename(demofile)
	sepline = "---------------------------------------------------------------------"
	println("\nExecuting $fileshort...")
	println(sepline)
	plot = evalfile(demofile)
	display(pdisp, plot)
end
end

:SampleCode_Executed
