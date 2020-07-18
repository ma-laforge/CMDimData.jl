#Test EasyData's read/write capabilities using sample/ plots
#-------------------------------------------------------------------------------
#=
Look for EasyData._write() & EasyData._read() near end of file.
=#


module CMDimData_SampleGenerator

using CMDimData
using CMDimData.EasyPlot
CMDimData.@includepkg EasyData

#Initialize display (must happen before defining specialized "getdemodisplay"):
EasyPlot.@initbackend()


#==Obtain plot rendering display:
===============================================================================#

#getdemodisplay: Potentially overwrite defaults:
#-------------------------------------------------------------------------------
#Default behaviour, just use provided display:
getdemodisplay(d::EasyPlot.EasyPlotDisplay) = d


if @isdefined(EasyPlotGrace)
#Improve display appearance a bit:
function getdemodisplay(d::EasyPlotGrace.PlotDisplay)
	d = EasyPlotGrace.PlotDisplay()
	plotdefaults = GracePlot.defaults(linewidth=2.5)
	d.args = tuple(plotdefaults, d.args...) #Improve appearance a bit
	return d
end
end


#==Helper functions
===============================================================================#
printsep(title) = println("\n", title, "\n", repeat("-", 80))


#==Show results
===============================================================================#
pdisp = getdemodisplay(EasyPlot.defaults.maindisplay)

pathlist = EasyPlot.demofilelist()
for filepath in pathlist
	filename = basename(filepath)
	savefile = joinpath("./", splitext(filename)[1] * ".hdf5")
	printsep("Executing $filepath...")
	plot = evalfile(filepath)
	display(pdisp, plot)

	#EasyData portion:
	@info("Writing $savefile...")
	EasyData._write(savefile, plot)
	@info("Reading back $savefile...")
	plot2 = EasyData._read(savefile, EasyPlot.Plot);
	set(plot2, title = "Compare Results: " * plot.title)
	display(pdisp, plot2)
end

end
:SampleCode_Executed
