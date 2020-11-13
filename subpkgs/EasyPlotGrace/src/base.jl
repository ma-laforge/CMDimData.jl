#EasyPlotGrace base types & core functions
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#
const NCOLORS_GRACEDFLT = 15 #Number of colors expected to be defined by Grace.
#NOTE: Assuming color 0 is white/background color (not to be used)


#==Base types
===============================================================================#
#Manages additional colors (leaves default ones intact):
#NOTE: 0 appears to be bkgnd color & 1: default frame color
mutable struct ColorMgr
	plt::GracePlot.Plot #Needed to send commands
	colormap::Dict{String, Int} #Maps #RRGGBB hex color string to registered color number
	nextcolor::Int
end
ColorMgr(p::GracePlot.Plot) = ColorMgr(p, Dict(), NCOLORS_GRACEDFLT+1)

mutable struct WfrmBuilder <: EasyPlot.AbstractWfrmBuilder
	ref::GracePlot.GraphRef #Axes reference
	theme::EasyPlot.Theme
	colormgr::ColorMgr
	fold::Optional{EasyPlot.FoldedAxis}
end


#==Registering new colors
===============================================================================#
const HEX_CODES = UInt8[
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
]
function int2hexcolorstr(v::UInt32)
	result = Array{UInt8}(undef, 7)
	result[1] = '#'
	for i in length(result):-1:2
		result[i] = HEX_CODES[(v & 0xF)+1]
		v >>= 4
	end
	return String(result)
end

function buildcmd_mapcolor(id::Int, colorval::UInt32, idstr::String)
	r = (colorval>>16) & 0xFF
	g = (colorval>>8) & 0xFF
	b = colorval & 0xFF
	result = "map color $id to ($r,$g,$b), \"$idstr\""
end

#Automatically adds color if does not exist:
function _getcoloridx(mgr::ColorMgr, v::Colorant)
	v = convert(RGB24, v)
	v = v.color
	colorid = int2hexcolorstr(v)
	idx = get(mgr.colormap, colorid, missing)
	if !ismissing(idx)
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
maplinewidth(::Nothing) = maplinewidth(1) #default

#Glyph size:
mapglyphsize(sz) = sz/2
mapglyphsize(::Nothing) = mapglyphsize(1) #default

#TODO: Support ColorScheme:
function _graceline(attr::EasyPlot.WfrmAttributes, mgr::ColorMgr)
	return line(style=attr.linestyle,
	            width=maplinewidth(attr.linewidth),
	            color=mapcolor(mgr, attr.linecolor),
	           )
end
function _graceglyph(attr::EasyPlot.WfrmAttributes, mgr::ColorMgr)
	nofill = (colorant"transparent" == attr.glyphfillcolor)
	glyphfillcolor = nofill ? colorant"white" : attr.glyphfillcolor
	return glyph(shape=attr.glyphshape,
	             size=mapglyphsize(attr.glyphsize),
	             linewidth=maplinewidth(attr.linewidth),
	             color=mapcolor(mgr, attr.glyphlinecolor),
	             fillcolor=mapfacecolor(mgr, glyphfillcolor),
	             fillpattern=(nofill ? 0 : 1)
	            )
end


#==AbstractWfrmBuilder implementation
===============================================================================#
EasyPlot.needsfold(b::WfrmBuilder) = b.fold

#Called by EasyPlot, for each individual DataF1 ∈ DataMD.
function EasyPlot.addwfrm(b::WfrmBuilder, d::DataF1, id::String,
	la::EasyPlot.LineAttributes, ga::EasyPlot.GlyphAttributes, strip::Int)
	attr = EasyPlot.WfrmAttributes(b.theme, la, ga) #Apply theme to attributes
	_line = _graceline(attr, b.colormgr)
	_glyph = _graceglyph(attr, b.colormgr)
	add(b.ref, d.x, d.y, _line, _glyph, id=id)
end


#==Plot building functions
===============================================================================#

#Render a particular EasyPlot.Plot:
function build(g::GracePlot.GraphRef, eplot::EasyPlot.Plot,
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

function build(gplot::GracePlot.Plot, ecoll::EasyPlot.PlotCollection)
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
		build(g, p, ecoll.theme, colormgr)
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

#Last line
