#Show how to display plots using EasyPlotPlots/Plots.jl
#-------------------------------------------------------------------------------
module CMDimData_SampleUsage

using CMDimData
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotPlots


#==Constants
===============================================================================#
demolist = EasyPlot.demofilelist()
backend = :gr
	#no display: {:hdf5}
	#Text-based {:unicodeplots}
	#GUI: {:gr, :inspectdr, :pgfplotsx}
	#Python-based {:pyplot}
	#Browser-based? {:plotly, :plotlyjs}
	##########deprecated: {:gadfly, :bokeh, :winston}


#==Helper functions
===============================================================================#
printsep(label, sep="-") = println("\n", label, "\n", repeat(sep, 80))
printheader(label) = printsep(label, "=")


#==Write EasyPlot plots to file
===============================================================================#
printsep("Write EasyPlot.Plot to file using `backend=:$backend`...")
plot = evalfile(demolist[1])
bld_headless = EasyPlot.getbuilder(:image, :PlotsJl, backend=backend)
	EasyPlot._write(:png, "sample_PlotsJl_$backend.png", bld_headless, plot)
	EasyPlot._write(:svg, "sample_PlotsJl_$backend.svg", bld_headless, plot)


#==Render sample EasyPlot plots
===============================================================================#
disp = EasyPlot.GUIDisplay(:PlotsJl, backend=backend)
for demofile in demolist
	fileshort = basename(demofile)
	printsep("Display $fileshort...")
	plot = evalfile(demofile)
	display(disp, plot)
end

end #module
:SampleCode_Executed
