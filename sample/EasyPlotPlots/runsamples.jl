#Run sample code
#-------------------------------------------------------------------------------

module CMDimData_SampleGenerator

using CMDimData
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotPlots


#==Constants
===============================================================================#
demolist = EasyPlot.demofilelist()
renderingtool = :gr
	#no display: {:hdf5}
	#Text-based {:unicodeplots}
	#GUI: {:gr, :inspectdr, :pgfplotsx}
	#Python-based {:pyplot}
	#Browser-based? {:plotly, :plotlyjs}
	##########deprecated: {:gadfly, :bokeh, :winston}
#pdisp = EasyPlotPlots.PlotDisplay()
pdisp = EasyPlotPlots.PlotDisplay(renderingtool)


#==Helper functions
===============================================================================#
printsep(title) = println("\n", title, "\n", repeat("-", 80))


#==Render sample EasyPlot plots
===============================================================================#
plot = evalfile(demolist[1])
#	display(pdisp, plot)
	EasyPlot.write_png("image.png", plot, pdisp)
#	EasyPlot.write_svg("image.svg", plot, pdisp)


#==Render sample EasyPlot plots
===============================================================================#
for demofile in demolist[1:end]
	fileshort = basename(demofile)
	printsep("Executing $fileshort...")
	plot = evalfile(demofile)
	display(pdisp, plot)
end

end
:SampleCode_Executed
#Last line
