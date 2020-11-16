#EasyPlotInspect Display functionnality
#-------------------------------------------------------------------------------


#==Types
===============================================================================#
mutable struct PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	#w/h of data area:
	wdata::Float64; hdata::Float64 #Deprecate
	#Add desired layout instead of wdata, hdata!
	args::Tuple
	kwargs::Base.Iterators.Pairs
	PlotDisplay(args...;
		wdata=InspectDR.DEFAULT_DATA_WIDTH, hdata=InspectDR.DEFAULT_DATA_HEIGHT, kwargs...) =
		new(wdata, hdata, args, kwargs)
end


#==Top-level rendering functions
===============================================================================#
#Do not overwrite Base.display... would circumvent display system.
EasyPlot._display(mplot::InspectDR.Multiplot) = display(InspectDR.GtkDisplay(), mplot)

function EasyPlot.render(d::PlotDisplay, ecoll::EasyPlot.PlotCollection)
	mplot = InspectDR.Multiplot() #d.kwargs...
	EasyPlot.render(mplot, ecoll)

	#Update with preferred defaults:
	for iplot in mplot.subplots
		layout = iplot.layout
		#Switch to overwriting style: setstyle!(layout, InspectDR.defaults.plotlayout, refresh=false)
		layout[:halloc_data] = d.wdata
		layout[:valloc_data] = d.hdata
	end

	return mplot
end

Base.showable(mime::MIME, ecoll::EasyPlot.PlotCollection, d::PlotDisplay) =
	method_exists(show, (IO, typeof(mime), InspectDR.Multiplot))

#Last line
