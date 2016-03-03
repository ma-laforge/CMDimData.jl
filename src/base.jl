#EasyPlotGrace base types & core functions
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
const NCOLORS_GRACE = 15 #Number of colors expected to be defined by Grace.
#NOTE: Assuming color 0 is white/background color (not to be used)


#==Base types
===============================================================================#
typealias NullOr{T} Union{Void, T} #Simpler than Nullable

type Axes{T} <: EasyPlot.AbstractAxes{T}
	ref::GracePlot.GraphRef #Axes reference
	theme::EasyPlot.Theme
	eye::NullOr{EasyPlot.EyeAttributes}
end
Axes(style::Symbol, ref::GracePlot.GraphRef, theme::EasyPlot.Theme, eye=nothing) =
	Axes{style}(ref, theme, eye)


#==Helper/mapping functions
===============================================================================#
warned_nocolorant = false
function warn_nocolorant()
	global warned_nocolorant
	if !warned_nocolorant
		info("Colorant values not yet supported.")
		warned_nocolorant = true
	end
end

#no default... use auto-color
#mapcolor(::Void) = mapcolor("black") #default
mapcolor(v) = v #::Void uses built-in auto color
mapcolor(v::Integer) = mod(v-1, NCOLORS_GRACE)+1 #use built-in Grace color map
mapcolor(v::Symbol) = string(v) #Use built-in Grace color names
function mapcolor(v::Colorant)
	warn_nocolorant()
	return nothing #Use built-in auto-color
end
mapfacecolor(v) = mapcolor(v) #In case we want to diverge

#Linewidth:
maplinewidth(w) = w
maplinewidth(::Void) = maplinewidth(1) #default

#Glyph size:
mapglyphsize(sz) = sz/2
mapglyphsize(::Void) = mapglyphsize(1) #default


function _graceline(wfrm::EasyPlot.Waveform)
	return line(style=wfrm.line.style,
	            width=maplinewidth(wfrm.line.width),
	            color=mapcolor(wfrm.line.color),
	           )
end

function _graceglyph(wfrm::EasyPlot.Waveform)
	color = wfrm.line.color
	if nothing == color; color = wfrm.glyph.color; end
	return glyph(shape=wfrm.glyph.shape,
	             size=mapglyphsize(wfrm.glyph.size),
	             linewidth=maplinewidth(wfrm.line.width),
	             color=mapcolor(color),
	             fillcolor=mapfacecolor(wfrm.glyph.color),
	             fillpattern=(nothing==wfrm.glyph.color?0:1)
	            )
end

#TODO: Support ColorScheme:
function _graceline(attr::EasyPlot.WfrmAttributes)
	return line(style=attr.linestyle,
	            width=maplinewidth(attr.linewidth),
	            color=mapcolor(attr.linecolor),
	           )
end
function _graceglyph(attr::EasyPlot.WfrmAttributes)
	nofill = (:transparent == attr.glyphfillcolor)
	glyphfillcolor = nofill? (:white): attr.glyphfillcolor
	return glyph(shape=attr.glyphshape,
	             size=mapglyphsize(attr.glyphsize),
	             linewidth=maplinewidth(attr.linewidth),
	             color=mapcolor(attr.glyphlinecolor),
	             fillcolor=mapfacecolor(glyphfillcolor),
	             fillpattern=(nofill?0:1)
	            )
end

#==Rendering functions
===============================================================================#

#Called by EasyPlot, for each individual DataF1 ∈ DataMD.
function EasyPlot.addwfrm(ax::Axes, d::DataF1, id::AbstractString,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes)
	attr = EasyPlot.WfrmAttributes(ax.theme, la, ga, resolvecolors=false) #Apply theme to attributes
	_line = _graceline(attr)
	_glyph = _graceglyph(attr)
	add(ax.ref, d.x, d.y, _line, _glyph, id=id)
end

#Render a paraticular subplot:
function _render(g::GracePlot.GraphRef, subplot::EasyPlot.Subplot, theme::EasyPlot.Theme, displaylegend::Bool)
	set(g, subtitle = subplot.title)

	#TODO Ugly: setting defaults like this should be done in EasyPlot
	ep = nothing
	if :eye == subplot.style
		ep = subplot.eye
		if nothing == ep.teye; ep.teye = ep.tbit; end
	end

	axes = Axes(subplot.style, g, theme, ep)

	for (i, wfrm) in enumerate(subplot.wfrmlist)
		EasyPlot.addwfrm(axes, wfrm, i)
	end

	autofit(g)
	srca = subplot.axes
	set(g, GracePlot.axes(
		xscale = srca.xscale, yscale = srca.yscale,
		xmin = srca.xmin, xmax = srca.xmax,
		ymin = srca.ymin, ymax = srca.ymax,
	))
	set(g, legend(display=displaylegend))

	#Apply x/y labels
	if srca.xlabel != nothing
		set(g, xlabel=srca.xlabel)
	end
	if srca.ylabel != nothing
		set(g, ylabel=srca.ylabel)
	end

	return g
end

function EasyPlot.render(gplot::GracePlot.Plot, eplot::EasyPlot.Plot; ncols::Int=1)
	nrows = div(length(eplot.subplots)-1, ncols)+1

	#Arrange basically allocates all subplots (GracePlot.Plot):
	arrange(gplot, (nrows, ncols))
	graphidx = 0

	for s in eplot.subplots
		g = graph(gplot, graphidx)
		_render(g, s, eplot.theme, eplot.displaylegend)
		graphidx += 1
	end

	if length(eplot.subplots) > 1
		w = get(gplot, :wview); h = get(gplot, :hview)
		vgap = 0.15 #Pick a reasonable value (cannot querry state)
		title = GracePlot.text(eplot.title, loctype=:view, size=1.5, loc=(w/2,h-vgap/2.5), just=:centercenter)
		GracePlot.addannotation(gplot, title)
#		info("EasyPlotGrace: Plot.title not supported for more than 1 subplot")
	else
		set(graph(gplot, 0), title = eplot.title)
	end

	redraw(gplot)
	return gplot
end


#==EasyPlot-level rendering functions
===============================================================================#

function EasyPlot.render(::EasyPlot.Backend{:Grace}, plot::EasyPlot.Plot, args...; ncols::Int=1, kwargs...)
	return render(GracePlot.new(args...; kwargs...), plot, ncols=ncols)
end

function Base.display(plot::GracePlot.Plot)
	redraw(plot)
	return plot
end

#Last line
