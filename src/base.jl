#EasyPlotMPL base types & core functions
#-------------------------------------------------------------------------------


#==Constants
===============================================================================#

const scalemap = Dict{Symbol, AbstractString}(
	:lin => "linear",
	:log => "log",
)

const linestylemap = Dict{Symbol, AbstractString}(
	:none    => "none",
	:solid   => "-",
	:dash    => "--",
	:dot     => ":",
	:dashdot => "-.",
)

const markermap = Dict{Symbol, AbstractString}(
	:none    => "",
	:square    => "s",
	:diamond   => "D", #Diagsquare; diamond is d
	:uarrow    => "^", :darrow => "v",
	:larrow    => "<", :rarrow => ">",
	:cross     => "+", :+ => "+",
	:diagcross => "x", :x => "x",
	:circle    => "o", :o => "o",
	:star      => "*", :* => "*",
)

const integercolormap = ASCIIString[
	"black", "blue", "green", "red", "cyan", "magenta", "yellow", "#7F7F7F"
]


#==Base types
===============================================================================#
type WfrmAttributes
	label
	color #linecolor
	linewidth
	linestyle
	marker
	markersize
	markerfacecolor
#	markeredgecolor
	markeredgewidth
	#fillstyle
end
WfrmAttributes(;label=nothing,
	color=nothing, linewidth=nothing, linestyle=nothing,
	marker=nothing, markersize=nothing, markerfacecolor=nothing) =
	WfrmAttributes(label, color, linewidth, linestyle,
		marker, markersize, markerfacecolor, 0
	)


#==Helper functions
===============================================================================#
mapcolor(v) = v
#mapcolor(v::Symbol) = string(v)
mapcolor(v::Integer) = integercolormap[1+(v-1)&0x7]

#Linewidth:
maplinewidth(w) = w
maplinewidth(w::Real) = 2*w
maplinewidth(::Void) = maplinewidth(1)

#Marker size:
mapmarkersize(w) = w
mapmarkersize(sz::Real) = 3*sz
mapmarkersize(::Void) = mapmarkersize(1)


WfrmAttributes(wfrm::EasyPlot.Waveform) =
	WfrmAttributes(label=wfrm.id, color=mapcolor(wfrm.line.color),
		linewidth=maplinewidth(wfrm.line.width),
		linestyle=get(linestylemap, wfrm.line.style, "-"),
		marker=get(markermap, wfrm.glyph.shape, ""),
		markersize=mapmarkersize(wfrm.glyph.size),
		markerfacecolor=mapcolor(wfrm.line.color),
	)


#==Rendering functions
===============================================================================#

function _add{T<:DataMD}(ax, d::T, args...; kwargs...)
	throw("$T datasets not supported.")
end

#Add DataF1 results:
function _add(ax, d::DataF1, a::WfrmAttributes)
	kwargs = Any[]
	for attrib in fieldnames(a)
		v = getfield(a,attrib)

		if v != nothing
			push!(kwargs, tuple(attrib, v))
		end
	end
	wfrm = ax[:plot](d.x, d.y; kwargs...)
end

#Add collection of DataHR{DataF1} results:
function _add(ax, d::DataHR{DataF1}, a::WfrmAttributes)
	curattrib = deepcopy(a)
	sweepnames = names(sweeps(d))
	for coords in subscripts(d)
		if nothing == a.color
			curattrib.color = mapcolor(coords[end])
		end
		values = parameter(d, coords)
		di = d.subsets[coords...]
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		curattrib.label = "$(a.label); $crnid"
		wfrm = _add(ax, di, curattrib)
	end
end

#Convert DataHR{Number} to DataHR{DataF1}:
function _add{T<:Number}(ax, d::DataHR{T}, a::WfrmAttributes)
	return _add(ax, DataHR{DataF1}(d), a)
end

#Add DataEye data to an eye diagram:
function _add(ax, d::EasyPlot.DataEye, a::WfrmAttributes)
	curattrib = deepcopy(a)
	if length(d.data) < 1; return; end
	_add(ax, d.data[1], a) #Id first element
	curattrib.label = nothing
	for i in 1:length(d.data)
		_add(ax, d.data[i], curattrib) #no id
	end
end

#Add collection of DataEye{DataEye} data to an eye diagram:
function _add(ax, d::DataHR{EasyPlot.DataEye}, a::WfrmAttributes)
	curattrib = deepcopy(a)
	sweepnames = names(sweeps(d))
	for coords in subscripts(d)
		if nothing == a.color
			curattrib.color = mapcolor(coords[end])
		end
		values = parameter(d, coords)
		di = d.subsets[coords...]
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		curattrib.label = "$(a.label); $crnid"
		wfrm = _add(ax, di, curattrib)
	end
end

#Add waveform to an x/y plot:
function _add(ax, wfrm::EasyPlot.Waveform)
	return _add(ax, wfrm.data, WfrmAttributes(wfrm))
end

#Add a waveform to an eye diagram:
function _add(ax, wfrm::EasyPlot.Waveform, param::EasyPlot.EyeAttributes)
	eye = EasyPlot.BuildEye(wfrm.data, param.tbit, param.teye, tstart=param.tstart)
	return _add(ax, eye, WfrmAttributes(wfrm))
end

function rendersubplot(ax, subplot::EasyPlot.Subplot)
	ax[:set_title](subplot.title)

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
	(xmin, xmax) = ax[:set_xlim]()
	if srca.xmin != nothing; xmin = srca.xmin; end
	if srca.xmax != nothing; xmax = srca.xmax; end
	(ymin, ymax) = ax[:set_ylim]()
	if srca.xmin != nothing; xmin = srca.xmin; end
	if srca.xmax != nothing; xmax = srca.xmax; end
	ax[:set_xlim](xmin, xmax)
	ax[:set_ylim](ymin, ymax)

	#Apply x/y scales:
	ax[:set_xscale](scalemap[srca.xscale])
	ax[:set_yscale](scalemap[srca.yscale])
	
	#Apply x/y labels:
	if srca.xlabel != nothing; ax[:set_xlabel](srca.xlabel); end
	if srca.ylabel != nothing; ax[:set_ylabel](srca.ylabel); end

	return ax
end

function render(fig::PyPlot.Figure, eplot::EasyPlot.Plot; ncols::Int=1)
	nrows = div(length(eplot.subplots)-1, ncols)+1
	subplotidx = 0

	for s in eplot.subplots
#		row = div(subplotidx, ncols) + 1
#		col = mod(subplotidx, ncols) + 1
		ax = fig[:add_subplot](nrows, ncols, subplotidx+1)
		rendersubplot(ax, s)
		if eplot.displaylegend; ax[:legend](); end
		subplotidx += 1
	end

	fig[:canvas][:draw]()
	return fig
end


#==EasyPlot-level rendering functions
===============================================================================#

function EasyPlot.render(::EasyPlot.Backend{:MPL}, plot::EasyPlot.Plot, args...; ncols::Int=1, kwargs...)
	fig = plt.figure(args...; kwargs...)
	fig[:suptitle](plot.title)
	return render(fig, plot, ncols=ncols)
end

function Base.display(fig::PyPlot.Figure)
	fig[:canvas][:draw]()
	return fig
end

#Last line
