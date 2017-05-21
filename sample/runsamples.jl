#Run sample code
#-------------------------------------------------------------------------------

using FileIO2
using EasyPlot


#==Obtain plot rendering display:
===============================================================================#

#initplotbackend: importing backend initializes module
#-------------------------------------------------------------------------------
function initplotbackend(d::EasyPlot.NullDisplay) #Use InspectDR as default
	eval(:(import EasyPlotInspect))
	return
end

function initplotbackend(d::EasyPlot.UninitializedDisplay)
	if :Grace == d.dtype
		eval(:(import EasyPlotGrace))
	elseif :MPL == d.dtype
		eval(:(import EasyPlotMPL))
	elseif :Qwt == d.dtype
		eval(:(import EasyPlotQwt))
	elseif :Plots == d.dtype
		eval(:(import EasyPlotPlots))
	elseif :Inspect == d.dtype
		eval(:(import EasyPlotInspect))
	else #Don't recognize requested display... use default:
		initplotbackend(EasyPlot.NullDisplay())
	end
	return
end

function initplotbackend(d)
	return #Already initialized
end

#getdemodisplay: Potentially overwrite defaults:
#-------------------------------------------------------------------------------
#Default behaviour, just use provided display:
getdemodisplay(d::EasyPlot.EasyPlotDisplay) = d

#Must initialize display before defining specialized "getdemodisplay":
initplotbackend(EasyPlot.defaults.maindisplay)

if isdefined(:EasyPlotGrace)
#Improve display appearance a bit:
function getdemodisplay(d::EasyPlotGrace.PlotDisplay)
	d = EasyPlotGrace.PlotDisplay()
	plotdefaults = GracePlot.defaults(linewidth=2.5)
	d.args = tuple(plotdefaults, d.args...) #Improve appearance a bit
	return d
end
end


#==Show results
===============================================================================#
pdisp = getdemodisplay(EasyPlot.defaults.maindisplay)

#for i in 4
for i in 1:4
	file = "./demo$i.jl"
	sepline = "---------------------------------------------------------------------"
	outfile = File(:png, joinpath("./", splitext(basename(file))[1] * ".png"))
	println("\nExecuting $file...")
	println(sepline)
	plotlist = evalfile(file)
	for plot in plotlist
		display(pdisp, plot)
	end
end

:SampleCode_Executed
