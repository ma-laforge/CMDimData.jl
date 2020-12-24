#EasyPlotMPL AbstractBuilder interface implementation
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
#HACK: showable works on Figure objects (not types)
#HACK: hardcoding supported mimes (might not be true for different backends)
const SUPPORTED_MIMES = Set(["image/svg+xml", "image/png"])
const SUPPORTED_BACKENDS = Set(["tk", "gtk3", "gtk", "qt", "wx"])


#==Types
===============================================================================#
mutable struct Builder <: EasyPlot.AbstractBuilder
	guimode::Bool
	backend::Symbol
	postproc::Optional{Function}
	args::Tuple
	kwargs::Base.Iterators.Pairs
end
EasyPlot.AbstractBuilder(::DS{:PyPlot}) = Builder #Register builder


#==Constructors
===============================================================================#
MPLState(b::Builder) = MPLState(false, b.backend, b.guimode)


#==Constructor interface
===============================================================================#
#Use same builder irrespective of target application:
function EasyPlot.getbuilder(::Target{T}, ::Type{Builder}, args...;
		postproc=nothing, backend=nothing, guimode::Bool=true, kwargs...) where T
	if isnothing(backend); backend = defaults.backend; end
	return Builder(guimode, backend, postproc, args, kwargs)
end


#==I/O interface
===============================================================================#
function EasyPlot._show(io::IO, mime::MIME, opt::EasyPlot.ShowOptions, fig::PyPlot.Figure)
	if !EasyPlot.isauto(opt.dim)
		@warn("Cannot currently specify plot size. Using defaults.")
	end
	show(io, mime, fig)
end

EasyPlot._showable(mime::MIME{T}, b::Builder) where T = in(string(T), SUPPORTED_MIMES)
	#method_exists(show, (IO, typeof(mime), PyPlot.Figure)) #Apparently not enough


#==Display interface
===============================================================================#
EasyPlot.displaygui(f::PyPlot.Figure) = f.show()


#==Plot building functions
===============================================================================#
function _build(ax, eplot::EasyPlot.Plot, theme::EasyPlot.Theme)
	ax.set_title(eplot.title)
	fold = isa(eplot.xaxis, EasyPlot.FoldedAxis) ? eplot.xaxis : nothing

	builder = WfrmBuilder(ax, theme, fold)
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
	ax.set_xlabel(eplot.xlabel)
	ax.set_ylabel(ylabel)

	#Apply x/y scales:
	ax.set_xscale(scalemap[xscale])
	ax.set_yscale(scalemap[yscale])

	#Apply x/y extents:
	(c_xmin, c_xmax) = ax.set_xlim() #Read in current limits
		isnan(xmin) && (xmin = c_xmin); isnan(xmax) && (xmax = c_xmax)
		ax.set_xlim(xmin, xmax)
	(c_ymin, c_ymax) = ax.set_ylim() #Read in current limits
		isnan(ymin) && (ymin = c_ymin); isnan(ymax) && (ymax = c_ymax)
		ax.set_ylim(ymin, ymax)

	return ax
end

function _build(fig::PyPlot.Figure, ecoll::EasyPlot.PlotCollection)
	ecoll = EasyPlot.condxfrm_multistrip(ecoll, "EasyPlotMPL") #Emulate multi-strip plots
	ncols = ecoll.ncolumns
	fig.suptitle(ecoll.title)
	nrows = div(length(ecoll.plotlist)-1, ncols)+1
	iplot = 0

	for plot in ecoll.plotlist
#		row = div(iplot, ncols) + 1
#		col = mod(iplot, ncols) + 1
		ax = fig.add_subplot(nrows, ncols, iplot+1)
		_build(ax, plot, ecoll.theme)
		if plot.legend; ax.legend(); end
		iplot += 1
	end

	fig.canvas.draw()
	return fig
end

function EasyPlot.build(b::Builder, ecoll::EasyPlot.PlotCollection)
	local fig=nothing
	origstate = _getstate()
	newstate = MPLState(b)
	try
		_applystate(newstate)
		fig = PyPlot.figure(b.args...; b.kwargs...)
		_build(fig, ecoll)
	finally
		#Do not restore guimode... PyPlot will not display properly
		origstate.guimode = newstate.guimode
		_applystate(origstate)
	end
	return fig
end


#Last line
