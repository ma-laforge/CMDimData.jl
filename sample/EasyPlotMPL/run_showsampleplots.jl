#Show how to display plots using EasyPlotMPL/PyPlot
#-------------------------------------------------------------------------------
module CMDimData_SampleUsage

using CMDimData
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotMPL


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
bld_headless = EasyPlot.getbuilder(:image, :PyPlot, guimode=false)
	EasyPlot._write(:png, "sample_PyPlot.png", bld_headless, plot)
	EasyPlot._write(:svg, "sample_PyPlot.svg", bld_headless, plot)


#==Display sample EasyPlot plots
===============================================================================#
for demofile in demolist
	fileshort = basename(demofile)
	printsep("Display $fileshort...")
	plot = evalfile(demofile)
	EasyPlot.displaygui(:PyPlot, plot)
end

end #module
:SampleCode_Executed
