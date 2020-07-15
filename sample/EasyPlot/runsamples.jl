#Run sample code
#-------------------------------------------------------------------------------

module CMDimData_SampleGenerator

#==Configuration
===============================================================================#
#List of backends to test:
#const BACKENDLIST = [:EasyPlotInspect, :EasyPlotGrace, :EasyPlotMPL]
const BACKENDLIST = [:EasyPlotGrace] #Grace is faster, if installed.

#List of backends where SVG file is not to be saved:
const NOSVG = [:EasyPlotGrace]

using CMDimData
using CMDimData.EasyPlot

#Import all backends before defining getdisplay() functions:
for bk in BACKENDLIST
	eval(:(CMDimData.@includepkg $bk))
end

#Used to dispatch functions with the help of symbols:
struct DS{T}; end
DS(s::Symbol) = DS{s}()


#==Helper functions
===============================================================================#
function printsep(title)
	println("\n", title, "\n", repeat("-", 80))
end

#Get an EasyPlotDisplay object:
getdisplay(::DS{T}; renderonly=false) where T = eval(:($T.PlotDisplay()))

if @isdefined EasyPlotMPL
function getdisplay(::DS{:EasyPlotMPL}; renderonly=false)
	return EasyPlotMPL.PlotDisplay(guimode=!renderonly)
end
end
if @isdefined EasyPlotGrace
import GracePlot
function getdisplay(::DS{:EasyPlotGrace}; renderonly=false)
	template = GracePlot.template("smallplot_mono")
	plotdefaults = GracePlot.defaults(linewidth=2.5)

	pdisp = EasyPlotGrace.PlotDisplay()
	#pdisp = EasyPlotGrace.PlotDisplay(template=template)
	#pdisp = EasyPlotGrace.PlotDisplay(plotdefaults)

	pdisp.guimode = !renderonly
	return pdisp
end
end
getdisplay(s::Symbol; kwargs...) = getdisplay(DS(s); kwargs...)


#==Main Code
===============================================================================#
function run_samples(filelist, bk::Symbol)
	pdisp = getdisplay(bk, renderonly=true)
	nosvg = in(bk, NOSVG)

	#Write an EasyPlot to file
	plot = evalfile(filelist[1])
		EasyPlot.write_png("image_$bk.png", plot, pdisp)
		!nosvg && EasyPlot.write_svg("image_$bk.svg", plot, pdisp)

	pdisp = getdisplay(bk)

	#Render sample EasyPlot plots
	for demofile in filelist
		fileshort = basename(demofile)
		printsep("Rendering $fileshort with $bk...")
		plot = evalfile(demofile)
		display(pdisp, plot)
	end
end


#==Start point
===============================================================================#
for bk in BACKENDLIST
	run_samples(EasyPlot.demofilelist(), bk)
end

end
:SampleCode_Executed
