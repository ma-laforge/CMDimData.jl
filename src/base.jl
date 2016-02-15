#EasyPlotQwt base types & core functions
#-------------------------------------------------------------------------------

#==Constants
===============================================================================#

const scalemap = Dict{Symbol, ASCIIString}(
	:lin => "lin",
	:log => "log",
)

const linestylemap = Dict{Symbol, ASCIIString}(
	:none    => "",
	:solid   => "-",
	:dash    => "--",
	:dot     => ":",
	:dashdot => "-.",
)

const markermap = Dict{Symbol, ASCIIString}(
	:none      => "",
	:square    => "s",
	:diamond   => "d",
	:uarrow    => "^", :darrow => "v",
	:larrow    => "<", :rarrow => ">",
	:cross     => "+", :+ => "+",
	:diagcross => "x", :x => "x",
	:circle    => "o", :o => "o",
	:star      => "*", :* => "*",
)

const integercolormap = ASCIIString[
	"black", "blue", "green", "red", "cyan", "magenta", "yellow", "gray"
]


#==Base types
===============================================================================#
type WfrmAttributes
	title #Not label, for some reason
	color #linecolor
	linewidth
	linestyle
	marker
	markersize
	markerfacecolor
	markeredgecolor
#	markeredgewidth #Not supported
#	fillstyle #Not supported
#==Unknown options:
	shade, fitted, curvestyle, curvetype, baseline
==#
end
WfrmAttributes(;label=nothing,
	color=nothing, linewidth=nothing, linestyle=nothing,
	marker=nothing, markersize=nothing, markerfacecolor=nothing) =
	WfrmAttributes(label, color, linewidth, linestyle,
		marker, markersize, markerfacecolor, color
	)


#==Helper functions
===============================================================================#
mapcolor(v) = v
#mapcolor(v::Symbol) = string(v)
mapcolor(v::Integer) = integercolormap[1+(v-1)&0x7]
#no default... use auto-color
#mapcolor(::Void) = mapcolor("black") #default
mapfacecolor(v) = mapcolor(v) #In case we want to diverge
mapfacecolor(::Void) = "white" #Hack to emulate fillstyle=none

#Linewidth:
maplinewidth(w) = w
maplinewidth(::Void) = maplinewidth(1) #default

#Marker size:
mapmarkersize(sz) = 5*sz
mapmarkersize(::Void) = mapmarkersize(1)

function maplinestyle(v::Symbol)
	const NOTSUPPORTED = "nosup"
	result = get(linestylemap, v, NOTSUPPORTED)
	if NOTSUPPORTED == result
		info("Line style not supported")
		result = maplinestyle(nothing)
	end
	return result
end
maplinestyle(::Void) = "-" #default

function mapmarkershape(v::Symbol)
	const NOTSUPPORTED = "nosup"
	result = get(markermap, v, NOTSUPPORTED)
	if "" == result
		result = nothing
	elseif NOTSUPPORTED == result
		info("Marker shape not supported")
		result = "o" #Use some supported marker
	end
	return result
end
mapmarkershape(::Void) = mapmarkershape(:none) #default (no marker)


function WfrmAttributes(wfrm::EasyPlot.Waveform)
	color = wfrm.line.color
	if nothing == color; color = wfrm.glyph.color; end
	return WfrmAttributes(label=wfrm.id,
		color=mapcolor(color),
		linewidth=maplinewidth(wfrm.line.width),
		linestyle=maplinestyle(wfrm.line.style),
		marker=mapmarkershape(wfrm.glyph.shape),
		markersize=mapmarkersize(wfrm.glyph.size),
		markerfacecolor=mapfacecolor(wfrm.glyph.color),
	)
end

function _setlim(ax::Axes, setfn::Symbol, _min, _max)
	hasmin = nothing!=min
	hasmax = nothing!=max
	if hasmin && hasmax
		ax[setfn] = (_min, _max)
	elseif (hasmin && !hasmax) || (hasmax && !hasmin)
		warn("Partial limits not supported: $setfn($_min, $_max)")
	end
end


#==Rendering functions
===============================================================================#

function _add{T<:DataMD}(ax, d::T, args...; kwargs...)
	throw("$T datasets not supported.")
end

#Add DataF1 results:
function _add(ax::Axes, d::DataF1, a::WfrmAttributes)
	kwargs = Any[]
	for attrib in fieldnames(a)
		v = getfield(a,attrib)

		if v != nothing
			push!(kwargs, tuple(attrib, v))
		end
	end

	#TODO: is result of add the "wfrm" we want to return?
	wfrm = Curve(d.x, d.y; kwargs...)
	add(ax, wfrm)
	return wfrm
end

#Add collection of DataRS{DataF1} results:
function _add(ax::Axes, d::DataRS{DataF1}, a::WfrmAttributes, crnid::ASCIIString="")
	crnid = ""==crnid? crnid: "$crnid / "
	curattrib = deepcopy(a)
	sweepname = d.sweep.id
	for i in 1:length(d.elem)
		if nothing == a.color
			curattrib.color = mapcolor(i)
		end
		v = d.sweep.v[i]
		curcrnid = "$crnid$sweepname=$v"
		curattrib.title = "$(a.title); $curcrnid"
		wfrm = _add(ax, d.elem[i], curattrib)
	end
end

#Add collection of DataRS{Number} results:
function _add{T<:Number}(ax::Axes, d::DataRS{T}, a::WfrmAttributes, crnid::ASCIIString="")
	curattrib = deepcopy(a)
	curattrib.title = "$(a.title); $crnid"
	return _add(ax, DataF1(d.sweep.v, d.elem), curattrib)
end

#Add collection of DataRS{DataRS} results:
function _add(ax::Axes, d::DataRS{DataRS}, a::WfrmAttributes, crnid::ASCIIString="")
	crnid = ""==crnid? crnid: "$crnid / "
	sweepname = d.sweep.id
	for i in 1:length(d.elem)
		v = d.sweep.v[i]
		curcrnid = "$crnid$sweepname=$v"
		wfrm = _add(ax, d.elem[i], a, curcrnid)
	end
end

#Add collection of DataHR{DataF1} results:
function _add(ax::Axes, d::DataHR{DataF1}, a::WfrmAttributes)
	curattrib = deepcopy(a)
	sweepnames = names(sweeps(d))
	for inds in subscripts(d)
		if nothing == a.color
			curattrib.color = mapcolor(inds[end])
		end
		values = coordinates(d, inds)
		di = d.elem[inds...]
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		curattrib.title = "$(a.title); $crnid"
		wfrm = _add(ax, di, curattrib)
	end
end

#Convert DataHR{Number} to DataHR{DataF1}:
function _add{T<:Number}(ax::Axes, d::DataHR{T}, a::WfrmAttributes)
	return _add(ax, DataHR{DataF1}(d), a)
end

#Add DataEye data to an eye diagram:
function _add(ax::Axes, d::EasyPlot.DataEye, a::WfrmAttributes)
	curattrib = deepcopy(a)
	if length(d.data) < 1; return; end
	_add(ax, d.data[1], a) #Id first element
	curattrib.title = nothing
	for i in 1:length(d.data)
		_add(ax, d.data[i], curattrib) #no id
	end
end

#Add collection of DataEye{DataEye} data to an eye diagram:
function _add(ax::Axes, d::DataRS{EasyPlot.DataEye}, a::WfrmAttributes, crnid::ASCIIString="")
	crnid = ""==crnid? crnid: "$crnid / "
	curattrib = deepcopy(a)
	sweepname = d.sweep.id
	for i in 1:length(d.elem)
		if nothing == a.color
			curattrib.color = mapcolor(i)
		end
		v = d.sweep.v[i]
		curcrnid = "$crnid$sweepname=$v"
		curattrib.title = "$(a.title); $curcrnid"
		wfrm = _add(ax, d.elem[i], curattrib)
	end
end

#Add collection of DataEye{DataEye} data to an eye diagram:
function _add(ax::Axes, d::DataHR{EasyPlot.DataEye}, a::WfrmAttributes)
	curattrib = deepcopy(a)
	sweepnames = names(sweeps(d))
	for inds in subscripts(d)
		if nothing == a.color
			curattrib.color = mapcolor(inds[end])
		end
		values = coordinates(d, inds)
		di = d.elem[inds...]
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		curattrib.title = "$(a.title); $crnid"
		wfrm = _add(ax, di, curattrib)
	end
end

#Add waveform to an x/y plot:
function _add(ax::Axes, wfrm::EasyPlot.Waveform)
	return _add(ax, wfrm.data, WfrmAttributes(wfrm))
end

#Add a waveform to an eye diagram:
function _add(ax::Axes, wfrm::EasyPlot.Waveform, param::EasyPlot.EyeAttributes)
	eye = EasyPlot.BuildEye(wfrm.data, param.tbit, param.teye, tstart=param.tstart)
	return _add(ax, eye, WfrmAttributes(wfrm))
end

function rendersubplot(ax::Axes, subplot::EasyPlot.Subplot)
	#TODO: add support for supblot title

	if :eye == subplot.style
		ep = subplot.eye
		if nothing == ep.teye; ep.teye = ep.tbit; end
		for wfrm in subplot.wfrmlist
			_add(ax, wfrm, ep)
		end
	else
		for wfrm in subplot.wfrmlist
			_add(ax, wfrm)
		end
	end

	srca = subplot.axes

	#Update axis limits:
	_lim = ax[:xlimits]
	(xmin, xmax) = _lim != nothing? _lim: (nothing, nothing)
	if srca.xmin != nothing; xmin = srca.xmin; end
	if srca.xmax != nothing; xmax = srca.xmax; end
	_lim = ax[:ylimits]
	(ymin, ymax) = _lim != nothing? _lim: (nothing, nothing)
	if srca.ymin != nothing; ymin = srca.ymin; end
	if srca.ymax != nothing; ymax = srca.ymax; end
	_setlim(ax, :set_xlim, xmin, xmax)
	_setlim(ax, :set_ylim, ymin, ymax)

	#Apply x/y scales:
	ax[:xscale] = scalemap[srca.xscale]
	ax[:yscale] = scalemap[srca.yscale]
	
	#Apply x/y labels:
	if srca.xlabel != nothing; ax[:xlabel] = (string(srca.xlabel), ""); end
	if srca.ylabel != nothing; ax[:ylabel] = (string(srca.ylabel), ""); end

	return ax
end

function render(fig::Figure, eplot::EasyPlot.Plot; ncols::Int=1)
	nrows = div(length(eplot.subplots)-1, ncols)+1
	subplotidx = 0

	for s in eplot.subplots
#		row = div(subplotidx, ncols) + 1
#		col = mod(subplotidx, ncols) + 1
		ax = subplot(fig, nrows, ncols, subplotidx+1)
		rendersubplot(ax, s)
		if eplot.displaylegend; add(ax, :legend); end
		subplotidx += 1
	end

	return fig
end


#==EasyPlot-level rendering functions
===============================================================================#

function Base.show(fig::Figure, args...; kwargs...)
	fig[:show]()
	app = GUICore.qapplication()
	#Blocking call:
	app[:exec_]() #Process app events
	#TODO: Find a version that is non-blocking
end

function EasyPlot.render(::EasyPlot.Backend{:Qwt}, plot::EasyPlot.Plot, args...; ncols::Int=1, kwargs...)
	fig = Figure()
	return render(fig, plot, ncols=ncols)
end

function Base.display(fig::Figure)
	show(fig)
	return fig
end

#Last line
