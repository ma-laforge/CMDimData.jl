#Show how to display plots using EasyPlotGrace/Grace
#-------------------------------------------------------------------------------
module CMDimData_SampleUsage

using CMDimData
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotGrace


#==Constants
===============================================================================#
demolist = EasyPlot.demofilelist()


#==Helper functions
===============================================================================#
printsep(label, sep="-") = println("\n", label, "\n", repeat(sep, 80))
printheader(label) = printsep(label, "=")

#Improve display appearance a bit:
function getgracebuilder(builderid::Symbol)
	target = (builderid==:Grace_headless) ? :image : :gui
	GracePlot = EasyPlotGrace.GracePlot
	template = GracePlot.template("smallplot_mono")
	plotdefaults = GracePlot.defaults(linewidth=2.5) #Improve appearance a bit

#	return EasyPlot.getbuilder(target, builderid, template=template)
	return EasyPlot.getbuilder(target, builderid, plotdefaults)
end


#==Main Code
===============================================================================#
function showplotfiles(filelist, builderid::Symbol)
	printheader("\n\nUsing builder :$builderid...")
	builder = getgracebuilder(builderid)

	#Write EasyPlot.Plot to file
	printsep("Write EasyPlot.Plot to file...")
	plot = evalfile(filelist[1])
		filepath = "sample_$builderid.png"
		EasyPlot._write(:png, filepath, builder, plot)

	#Display sample EasyPlot plots
	for plotfile in filelist
		fileshort = basename(plotfile)
		printsep("Display $fileshort with $builderid...")
		plot = evalfile(plotfile)
		EasyPlot.displaygui(builder, plot)
	end
end

showplotfiles(demolist, :Grace)
showplotfiles(demolist, :Grace_headless)

end
:SampleCode_Executed
