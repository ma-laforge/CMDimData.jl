#EasyPlotGrace base types & core functions
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
const NCOLORS_GRACEDFLT = 15 #Number of colors expected to be defined by Grace.
#NOTE: Assuming color 0 is white/background color (not to be used)

immutable FlagType{T}; end
const NOTFOUND = FlagType{:NOTFOUND}()


#==Base types
===============================================================================#
typealias NullOr{T} Union{Void, T} #Simpler than Nullable

#Manages additional colors (leaves default ones intact):
#NOTE: 0 appears to be bkgnd color & 1: default frame color
type ColorMgr
	plt::GracePlot.Plot #Needed to send commands
	colormap::Dict{String, Int} #Maps #RRGGBB hex color string to registered color number
	nextcolor::Int
end
ColorMgr(p::GracePlot.Plot) = ColorMgr(p, Dict(), NCOLORS_GRACEDFLT+1)

type Axes{T} <: EasyPlot.AbstractAxes{T}
	ref::GracePlot.GraphRef #Axes reference
	theme::EasyPlot.Theme
	colormgr::ColorMgr
	eye::NullOr{EasyPlot.EyeAttributes}
end
Axes(style::Symbol, ref::GracePlot.GraphRef, theme::EasyPlot.Theme, colormgr::ColorMgr, eye=nothing) =
	Axes{style}(ref, theme, colormgr, eye)


#==Registering new colors
===============================================================================#
const HEX_CODES = UInt8[
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
]
function int2hexcolorstr(v::UInt)
	result = Array(UInt8, 7)
	result[1] = '#'
	for i in length(result):-1:2
		result[i] = HEX_CODES[(v & 0xF)+1]
		v >>= 4
	end
	return String(result)
end

function buildcmd_mapcolor(id::Int, colorval::UInt, idstr::String)
	colorval = Int32(colorval) #Don't display results in hex
	r = (colorval>>16) & 0xFF
	g = (colorval>>8) & 0xFF
	b = colorval & 0xFF
	result = "map color $id to ($r,$g,$b), \"$idstr\""
end

#Automatically adds color if does not exist:
function _getcoloridx(mgr::ColorMgr, v::Colorant)
	v = convert(RGB24, v)
	v = UInt(v.color)
	colorid = int2hexcolorstr(v)
	idx = get(mgr.colormap, colorid, NOTFOUND)
	if idx != NOTFOUND
		return idx
	end

	idx = mgr.nextcolor
	cmd = buildcmd_mapcolor(idx, v, colorid)
	GracePlot.sendcmd(mgr.plt, cmd)
	mgr.colormap[colorid] = idx
	mgr.nextcolor += 1
	return idx
end


#==Mapping functions
===============================================================================#
mapcolor(mgr::ColorMgr, v::Colorant) = _getcoloridx(mgr, v)
mapfacecolor(mgr::ColorMgr, v) = mapcolor(mgr, v) #In case we want to diverge

#Linewidth:
maplinewidth(w) = w
maplinewidth(::Void) = maplinewidth(1) #default

#Glyph size:
mapglyphsize(sz) = sz/2
mapglyphsize(::Void) = mapglyphsize(1) #default

#TODO: Support ColorScheme:
function _graceline(attr::EasyPlot.WfrmAttributes, mgr::ColorMgr)
	return line(style=attr.linestyle,
	            width=maplinewidth(attr.linewidth),
	            color=mapcolor(mgr, attr.linecolor),
	           )
end
function _graceglyph(attr::EasyPlot.WfrmAttributes, mgr::ColorMgr)
	nofill = (EasyPlot.COLOR_TRANSPARENT == attr.glyphfillcolor)
	glyphfillcolor = nofill? EasyPlot.COLOR_WHITE: attr.glyphfillcolor
	return glyph(shape=attr.glyphshape,
	             size=mapglyphsize(attr.glyphsize),
	             linewidth=maplinewidth(attr.linewidth),
	             color=mapcolor(mgr, attr.glyphlinecolor),
	             fillcolor=mapfacecolor(mgr, glyphfillcolor),
	             fillpattern=(nofill?0:1)
	            )
end


#==Rendering functions
===============================================================================#

#Called by EasyPlot, for each individual DataF1 ∈ DataMD.
function EasyPlot.addwfrm(ax::Axes, d::DataF1, id::String,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes)
	attr = EasyPlot.WfrmAttributes(ax.theme, la, ga) #Apply theme to attributes
	_line = _graceline(attr, ax.colormgr)
	_glyph = _graceglyph(attr, ax.colormgr)
	add(ax.ref, d.x, d.y, _line, _glyph, id=id)
end

#Render a paraticular subplot:
function _render(g::GracePlot.GraphRef, subplot::EasyPlot.Subplot,
	theme::EasyPlot.Theme, colormgr::ColorMgr, displaylegend::Bool)
	set(g, subtitle = subplot.title)

	#TODO Ugly: setting defaults like this should be done in EasyPlot
	ep = nothing
	if :eye == subplot.style
		ep = subplot.eye
		if nothing == ep.teye; ep.teye = ep.tbit; end
	end

	axes = Axes(subplot.style, g, theme, colormgr, ep)

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

function EasyPlot.render(gplot::GracePlot.Plot, eplot::EasyPlot.Plot)
	ncols = eplot.ncolumns
	nrows = div(length(eplot.subplots)-1, ncols)+1
	colormgr = ColorMgr(gplot)

	#Arrange basically allocates all subplots (GracePlot.Plot):
	arrange(gplot, (nrows, ncols))
	graphidx = 0

	for s in eplot.subplots
		g = graph(gplot, graphidx)
		_render(g, s, eplot.theme, colormgr, eplot.displaylegend)
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

#Last line
