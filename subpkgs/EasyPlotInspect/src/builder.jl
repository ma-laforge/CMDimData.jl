#EasyPlotInspect AbstractBuilder interface implementation
#-------------------------------------------------------------------------------


#==Types
===============================================================================#
mutable struct Builder <: EasyPlot.AbstractBuilder
	postproc::Optional{Function}
	#TODO: Support passing PlotLayout by argument???
end
EasyPlot.AbstractBuilder(::DS{:InspectDR}) = Builder #Register builder


#==Constructor interface
===============================================================================#
#Use same builder irrespective of target application:
function EasyPlot.getbuilder(::Target{T}, ::Type{Builder}; postproc=nothing) where T
	return Builder(postproc)
end


#==I/O interface
===============================================================================#
function EasyPlot._show(io::IO, mime::MIME, opt::EasyPlot.ShowOptions, plot::InspectDR.Multiplot)
	if EasyPlot.isfixed(opt.dim)
		InspectDR._show(io, mime, plot, opt.dim.w, opt.dim.h)
	else
		InspectDR.show(io, mime, plot) #Uses dimension values in plot
	end
	return
end
EasyPlot._show(io::IO, mime::MIME, opt::EasyPlot.ShowOptions, plot::InspectDR.GtkPlot) =
	EasyPlot._show(io, mime, opt, plot.src)

EasyPlot._showable(mime::MIME, b::Builder) =
	method_exists(show, (IO, typeof(mime), InspectDR.Multiplot))


#==Display interface
===============================================================================#
EasyPlot.displaygui(mplot::InspectDR.Multiplot) = display(InspectDR.GtkDisplay(), mplot)
EasyPlot.displaygui(gplot::InspectDR.GtkPlot) = gplot #Should we force a display??


#==Plot building functions
===============================================================================#
function _build(eplot::EasyPlot.Plot, theme::EasyPlot.Theme)
	iplot = InspectDR.Plot2D()
	fold = isa(eplot.xaxis, EasyPlot.FoldedAxis) ? eplot.xaxis : nothing
	layout = iplot.layout #Reference
		layout[:enable_legend] = eplot.legend

	#x-axis properties:
	iplot.xext_full = InspectDR.PExtents1D(eplot.xext.min, eplot.xext.max)
	iplot.xscale = InspectDR.AxisScale(scalemap[Symbol(eplot.xaxis)])

	#Want more resolution on y-axis than default:
	#TODO: is there a better way???
	_yaxisscale(s::Symbol) = InspectDR.AxisScale(s, tgtmajor=8, tgtminor=2)

	#y-strip properties:
	iplot.strips = [] #Reset
	for srcstrip in eplot.ystriplist
		strip = InspectDR.GraphStrip()
		push!(iplot.strips, strip)
		strip.yscale = _yaxisscale(scalemap[srcstrip.scale])
		strip.yext_full = InspectDR.PExtents1D(srcstrip.ext.min, srcstrip.ext.max)
	end

	#Apply x/y labels:
	a = iplot.annotation
	a.title = eplot.title
	a.xlabel = eplot.xlabel
	a.ylabels = String[strip.axislabel for strip in eplot.ystriplist]
	a.ystriplabels = String[strip.striplabel for strip in eplot.ystriplist]

	#Add data using EasyPlot.AbstractWfrmBuilder interface:
	wfrmbuilder = WfrmBuilder(iplot, theme, fold)
	for (i, wfrm) in enumerate(eplot.wfrmlist)
		EasyPlot.addwfrm(wfrmbuilder, wfrm, i)
	end
	
	return iplot
end

#Method build(::Multiplot, PlotCollection) needed for live-slice:
function EasyPlot.build(mplot::InspectDR.Multiplot, ecoll::EasyPlot.PlotCollection)
	layout = mplot.layout #Reference
		layout[:ncolumns] = ecoll.ncolumns
	mplot.title = ecoll.title

	mplot.subplots=[] #Start fresh in case being overwritten
	for eplot in ecoll.plotlist
		plot = _build(eplot, ecoll.theme)
		add(mplot, plot)
	end

	return mplot
end

function EasyPlot.build(b::Builder, ecoll::EasyPlot.PlotCollection)
	mplot = InspectDR.Multiplot()
	return EasyPlot.build(mplot, ecoll)
end

#Last line
