#EasyPlotGrace AbstractBuilder interface implementation
#-------------------------------------------------------------------------------
#=NOTE:
 - TODO: Not using defaults.renderdpi or DEFAULT_RENDERDPI
=#


#==Types
===============================================================================#
mutable struct Builder{T} <: EasyPlot.AbstractBuilder
	dpi::Int
	postproc::Optional{Function}
	args::Tuple
	kwargs::Base.Iterators.Pairs
end
const GUIBuilder = Builder{:gui}
const HeadlessBuilder = Builder{:headless}
EasyPlot.AbstractBuilder(::DS{:Grace}) = GUIBuilder #Register builder
EasyPlot.AbstractBuilder(::DS{:Grace_headless}) = HeadlessBuilder #Register builder


#==Helper functions
===============================================================================#
isheadless(::Builder) = false
isheadless(::HeadlessBuilder) = true


#==Constructor interface
===============================================================================#
#Use same builder irrespective of target application:
function EasyPlot.getbuilder(::Target{T}, btype::Type{Builder{BT}}, args...;
		postproc=nothing, dpi=GracePlot.DEFAULT_DPI, kwargs...) where {T, BT}
	return btype(dpi, postproc, args, kwargs)
end

#But can't have a gui in headless mode:
function EasyPlot.getbuilder(::Target{:gui}, btype::Type{HeadlessBuilder}, args...;
		postproc=nothing, dpi=GracePlot.DEFAULT_DPI, kwargs...)
	error("Cannot create a GUI-enabled builder in headless mode")
end


#==I/O interface
===============================================================================#
function EasyPlot._show(io::IO, mime::MIME, opt::EasyPlot.ShowOptions, plot::GracePlot.Plot)
	if !EasyPlot.isauto(opt.dim)
		@warn("Cannot currently specify plot size. Using plot defaults.")
		#NOTE: Grace supports rescaling through DPI only.
	end
	GracePlot.show(io, mime, plot) #Uses dimension values in plot
end

EasyPlot._showable(mime::MIME, b::Builder) =
	hasmethod(show, (IO, typeof(mime), GracePlot.Plot))


#==Display interface
===============================================================================#
#Can only redraw (always visible if !headless):
EasyPlot.displaygui(plot::GracePlot.Plot) = (redraw(plot); return plot)


#==Plot building functions
===============================================================================#
#Render a particular EasyPlot.Plot:
function _build(g::GracePlot.GraphRef, eplot::EasyPlot.Plot,
	theme::EasyPlot.Theme, colormgr::ColorMgr)
	set(g, subtitle = eplot.title)
	fold = isa(eplot.xaxis, EasyPlot.FoldedAxis) ? eplot.xaxis : nothing

	builder = WfrmBuilder(g, theme, colormgr, fold)

	for (i, wfrm) in enumerate(eplot.wfrmlist)
		EasyPlot.addwfrm(builder, wfrm, i)
	end

	autofit(g)

	#x-axis properties:
	xmin = eplot.xext.min; xmax = eplot.xext.max
	xscale = Symbol(eplot.xaxis)

	ymin, ymax = (NaN, NaN)
	yscale = :lin
	ylabel = ""
	if length(eplot.ystriplist) > 0
		strip = eplot.ystriplist[1]
		ymin = strip.ext.min; ymax = strip.ext.max
		yscale = strip.scale
		ylabel = strip.axislabel
	end

	#Translate NaN -> nothing (supported by GracePlot).
	isnan(xmin) && (xmin=nothing); isnan(xmax) && (xmax=nothing)
	isnan(ymin) && (ymin=nothing); isnan(ymax) && (ymax=nothing)

	#Apply axes & scale settings:
	set(g, GracePlot.paxes(
		xscale = xscale, yscale = yscale,
		xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
	))
	set(g, legend(display=eplot.legend))

	#Apply x/y labels
	if eplot.xlabel != nothing
		set(g, xlabel=eplot.xlabel)
	end
	if ylabel != nothing
		set(g, ylabel=ylabel)
	end

	return g
end

function _build(gplot::GracePlot.Plot, ecoll::EasyPlot.PlotCollection)
	ecoll = EasyPlot.condxfrm_multistrip(ecoll, "EasyPlotGrace") #Emulate multi-strip plots
	ncols = ecoll.ncolumns
	nrows = div(length(ecoll.plotlist)-1, ncols)+1
	colormgr = ColorMgr(gplot)

	#Arrange basically allocates all subplots (GracePlot.Plot):
	arrange(gplot, (nrows, ncols))
	graphidx = 0

	title = ecoll.title
	for p in ecoll.plotlist
		g = graph(gplot, graphidx)
		_build(g, p, ecoll.theme, colormgr)
		graphidx += 1
	end

	if length(ecoll.plotlist) > 1
		#Grace has a centered title & subtitle for each subplot.
		#Thus, if we want a centered title with a multi-plot output,
		#we have to do it manually:
		w = get(gplot, :wview); h = get(gplot, :hview)
		vgap = 0.15 #Pick a reasonable value (cannot querry state)
		title = GracePlot.text(ecoll.title, loctype=:view, size=1.5, loc=(w/2,h-vgap/2.5), just=:centercenter)
		GracePlot.addannotation(gplot, title)
	else
		set(graph(gplot, 0), title = ecoll.title)
	end

	redraw(gplot)
	return gplot
end

function EasyPlot.build(b::Builder, ecoll::EasyPlot.PlotCollection)
	plot = GracePlot.new(b.args...; guimode=!isheadless(b), dpi=b.dpi, b.kwargs...)
	return _build(plot, ecoll)
end

#Last line
