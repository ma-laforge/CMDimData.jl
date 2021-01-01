#Show how to display plots using EasyPlotGrace/InspectDR
#-------------------------------------------------------------------------------
module CMDimData_SampleUsage

using CMDimData
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotInspect


#==Constants
===============================================================================#
demolist = EasyPlot.demofilelist()


#==Helper functions
===============================================================================#
printsep(label, sep="-") = println("\n", label, "\n", repeat(sep, 80))
printheader(label) = printsep(label, "=")


#==Write EasyPlot plots to file
===============================================================================#
printsep("Write EasyPlot.Plot to file...")
plot = evalfile(demolist[1])
	EasyPlot._write(:png, "sample_InspectDR.png", :InspectDR, plot, dim=set(w=640, h=480))
	EasyPlot._write(:svg, "sample_InspectDR.svg", :InspectDR, plot)


#==Render sample EasyPlot plots
===============================================================================#
for demofile in demolist
	fileshort = basename(demofile)
	savefile = joinpath(splitext(fileshort)[1] * ".png")

	printsep("Display $fileshort...")
	plot = evalfile(demofile)
	EasyPlot.displaygui(:InspectDR, plot)
#	EasyPlot._write(:png, savefile, :InspectDR, plot, dim=set(w=640, h=480))
end

end #module
:SampleCode_Executed
