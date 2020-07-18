#Run sample code
#-------------------------------------------------------------------------------

module CMDimData_SampleGenerator

using CMDimData
using CMDimData.EasyPlot

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

for i in 1:4
	file = "./demo$i.jl"
	outfile = joinpath("./", splitext(basename(file))[1] * ".png")
	printsep("Executing $file...")
	plotlist = evalfile(file)
	for plot in plotlist
		display(pdisp, plot)
	end
end

end
:SampleCode_Executed
