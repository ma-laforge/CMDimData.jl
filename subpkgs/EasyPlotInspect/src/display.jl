#EasyPlotInspect Display functionnality
#-------------------------------------------------------------------------------


#==Types
===============================================================================#
mutable struct PlotDisplay <: EasyPlot.EasyPlotDisplay #Don't export.  Qualify with Module
	#w/h of data area:
	wdata::Float64
	hdata::Float64
	args::Tuple
	kwargs::Base.Iterators.Pairs
	PlotDisplay(args...;
		wdata=InspectDR.DEFAULT_DATA_WIDTH, hdata=InspectDR.DEFAULT_DATA_HEIGHT, kwargs...) =
		new(wdata, hdata, args, kwargs)
end


#==Top-level rendering functions
===============================================================================#
#Do not overwrite Base.display... would circumvent display system.
function EasyPlot._display(mplot::InspectDR.Multiplot)
	gplot = display(InspectDR.GtkDisplay(), mplot)
	nothing
end

function EasyPlot.render(d::PlotDisplay, ecoll::EasyPlot.PlotCollection)
	mplot = InspectDR.Multiplot() #d.kwargs...
	layout = InspectDR.StyleType(InspectDR.defaults.plotlayout)
	layout[:halloc_data] = d.wdata
	layout[:valloc_data] = d.hdata
	render(mplot, ecoll, layout.values)
	return mplot
end

Base.showable(mime::MIME, ecoll::EasyPlot.PlotCollection, d::PlotDisplay) =
	method_exists(show, (IO, typeof(mime), InspectDR.Multiplot))

#Last line
