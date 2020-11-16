#EasyPlotPlots AbstractBuilder interface implementation
#-------------------------------------------------------------------------------


#==Types
===============================================================================#
mutable struct Builder <: EasyPlot.AbstractBuilder
	backend::Symbol
	postproc::Optional{Function}
	args::Tuple
	kwargs::Base.Iterators.Pairs
end
EasyPlot.AbstractBuilder(::DS{:PlotsJl}) = Builder #Register builder


#==Constructor interface
===============================================================================#
#Use same builder irrespective of target application:
function EasyPlot.getbuilder(::Target{T}, ::Type{Builder}, args...;
		postproc=nothing, backend=nothing, kwargs...) where T
	if isnothing(backend); backend = defaults.backend; end
	return Builder(backend, postproc, args, kwargs)
end

function EasyPlot._show(io::IO, mime::MIME, opt::EasyPlot.ShowOptions, fig::FigureMulti)
	if EasyPlot.isfixed(opt.dim)
		@warn("Cannot currently specify plot size. Using defaults.")
	end
	show(io, mime, fig.p)
end

#Currently no support for non-FigureMulti plots... but could generate a single image...:
EasyPlot._show(io::IO, mime::MIME, opt::EasyPlot.ShowOptions, fig::Figure) =
	throw(MethodError(EasyPlot._show, (io, mime, opt, fig)))

#Module does not yet support other inline formats (must figure out how)
EasyPlot._showable(mime::MIME, b::Builder) = false
#Assume PNG is supported by all backends:
EasyPlot._showable(mime::MIME"image/png", b::Builder) = true


#==Display interface
===============================================================================#
EasyPlot.displaygui(fig::FigureMulti) = display(fig.p)
function EasyPlot.displaygui(fig::FigureSng)
	for s in fig.subplots
		display(s) #Defined in Plots.jl
	end
	nothing
end


#==Build interface
===============================================================================#
function _build(sp::Plots.Subplot, eplot::EasyPlot.Plot, theme::EasyPlot.Theme)
	Plots.title!(sp, eplot.title)
	Plots.plot!(sp, legend=eplot.legend)
	fold = isa(eplot.xaxis, EasyPlot.FoldedAxis) ? eplot.xaxis : nothing

	builder = WfrmBuilder(sp, theme, fold)
	for (i, wfrm) in enumerate(eplot.wfrmlist)
		EasyPlot.addwfrm(builder, wfrm, i)
	end

	#x-axis properties:
	xscale = Symbol(eplot.xaxis)
	xmin = eplot.xext.min; xmax = eplot.xext.max

	#y-axis properties:
	ylabel = ""
	yscale = :lin
	ymin, ymax = (NaN, NaN)
	if length(eplot.ystriplist) > 0
		strip = eplot.ystriplist[1]
		ylabel = strip.axislabel
		yscale = strip.scale
		ymin = strip.ext.min; ymax = strip.ext.max
	end

	#Apply x/y labels:
	Plots.xlabel!(sp, eplot.xlabel)
	Plots.ylabel!(sp, ylabel)

	#Apply x/y scales:
	Plots.plot!(sp, xscale=scalemap[xscale], yscale=scalemap[yscale])

	#Update axis limits:
	xlims!(sp, (xmin, xmax))
	ylims!(sp, (ymin, ymax))
	return sp
end

function _build(fig::Figure, ecoll::EasyPlot.PlotCollection)
	ecoll = EasyPlot.condxfrm_multistrip(ecoll, "EasyPlotPlots") #Emulate multi-strip plots
	ncols = ecoll.ncolumns
	nsubplots = length(ecoll.plotlist)
	plt = addsubplots(fig, ncols, nsubplots)

	for (i, plot) in enumerate(ecoll.plotlist)
		sp = getsubplot(fig, i)
		_build(sp, plot, ecoll.theme)
	end

	return fig
end

function EasyPlot.build(b::Builder, ecoll::EasyPlot.PlotCollection)
	local fig = nothing
	try
		bknd = Plots.backend(b.backend) #Activate backend
		fig = Figure(b.backend)
		_build(fig, ecoll)
	finally
		#TODO: Restore state
	end
	return fig
end

#Last line
