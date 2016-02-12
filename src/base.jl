#EasyPlotGrace base types & core functions
#-------------------------------------------------------------------------------


#==Base types
===============================================================================#

#==Helper/mapping functions
===============================================================================#

mapcolor(v) = v
mapcolor(v::Symbol) = string(v)
#mapcolor(v::Integer) = integercolormap[1+(v-1)&0x7]
#no default... use auto-color
#mapcolor(::Void) = mapcolor("black") #default
mapfacecolor(v) = mapcolor(v) #In case we want to diverge


#Linewidth:
maplinewidth(w) = w
maplinewidth(::Void) = maplinewidth(1) #default

#Glyph size:
mapglyphsize(sz) = sz/2
mapglyphsize(::Void) = mapglyphsize(1) #default


#==Rendering functions
===============================================================================#

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

function _add{T<:DataMD}(g::GracePlot.GraphRef, d::T, args...; kwargs...)
	throw("$T datasets not supported.")
end

#Add DataF1 results:
function _add(g::GracePlot.GraphRef, d::DataF1, args...; kwargs...)
	add(g, d.x, d.y, args...; kwargs...)
end

#Add collection of DataRS{DataF1} results:
function _add(g::GracePlot.GraphRef, d::DataRS{DataF1}, _line::LineAttributes, _glyph::GlyphAttributes; id::AbstractString="", crnid::ASCIIString="")
	sweepname = d.sweep.id
	for i in 1:length(d.elem)
		dfltline = line(color=i) #will be used unless _line overwites it...
		v = d.sweep.v[i]
		di = d.elem[i]
		crnid=join([crnid, "$sweepname=$v"], " / ")
		add(g, di.x, di.y, dfltline, _line, _glyph, id="$id; $crnid")
	end
end

#Add collection of DataRS{DataF1} results:
function _add{T<:Number}(g::GracePlot.GraphRef, d::DataRS{T}, _line::LineAttributes, _glyph::GlyphAttributes; id::AbstractString="", crnid::ASCIIString="")
	add(g, d.sweep.v, d.elem, _line, _glyph, id="$id; $crnid")
end

#Add collection of DataRS{DataRS} results:
function _add(g::GracePlot.GraphRef, d::DataRS{DataRS}, _line::LineAttributes, _glyph::GlyphAttributes; id::AbstractString="", crnid::ASCIIString="")
	sweepname = d.sweep.id
	for i in 1:length(d.elem)
		v = d.sweep.v[i]
		crnid=join([crnid, "$sweepname=$v"], " / ")
		_add(g, d.elem[i], _line, _glyph, id=id, crnid=crnid)
	end
end

#Add collection of DataHR{DataF1} results:
function _add(g::GracePlot.GraphRef, d::DataHR{DataF1}, _line::LineAttributes, _glyph::GlyphAttributes; id::AbstractString="")
	sweepnames = names(sweeps(d))
	for inds in subscripts(d)
		dfltline = line(color=inds[end]) #will be used unless _line overwites it...
		values = coordinates(d, inds)
		di = d.elem[inds...]
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		add(g, di.x, di.y, dfltline, _line, _glyph, id="$id; $crnid")
	end
end

#Convert DataHR{Number} to DataHR{DataF1}:
function _add{T<:Number}(g::GracePlot.GraphRef, d::DataHR{T}, _line::LineAttributes, _glyph::GlyphAttributes; id::AbstractString="")
	return _add(g, DataHR{DataF1}(d), _line, _glyph; id=id)
end

#Add DataEye data to an eye diagram:
function _add(g::GracePlot.GraphRef, d::EasyPlot.DataEye, _line::LineAttributes, _glyph::GlyphAttributes; id::AbstractString="")
	if length(d.data) < 1; return; end
	_add(g, d.data[1], _line, _glyph; id=id) #Id first element
	for i in 1:length(d.data)
		_add(g, d.data[i], _line, _glyph) #no id
	end
end

#Add collection of DataEye{DataEye} data to an eye diagram:
function _add(g::GracePlot.GraphRef, d::DataRS{EasyPlot.DataEye}, _line::LineAttributes, _glyph::GlyphAttributes; id::AbstractString="", crnid::ASCIIString="")
	sweepname = d.sweep.id
	for i in 1:length(d.elem)
		#Adapt default attributes for multi-dimensional data:
		mdline = line(color=i) #will be used unless _line overwites it...
		GracePlot.copynew!(mdline, _line)
		v = d.sweep.v[i]
		di = d.elem[i]
		crnid=join([crnid, "$sweepname=$v"], " / ")
		_add(g, d.elem[i], mdline, _glyph, id="$id; $crnid")
	end
end

#Add collection of DataEye{DataEye} data to an eye diagram:
function _add(g::GracePlot.GraphRef, d::DataHR{EasyPlot.DataEye}, _line::LineAttributes, _glyph::GlyphAttributes; id::AbstractString="")
	sweepnames = names(sweeps(d))
	for inds in subscripts(d)
		#Adapt default attributes for multi-dimensional data:
		mdline = line(color=inds[end]) #will be used unless _line overwites it...
		GracePlot.copynew!(mdline, _line)
		values = coordinates(d, inds)
		di = d.elem[inds...]
		crnid=join(["$k=$v" for (k,v) in zip(sweepnames,values)], " / ")
		_add(g, di, mdline, _glyph, id="$id; $crnid")
	end
end

#Add a waveform to an x/y plot:
function _add(g::GracePlot.GraphRef, wfrm::EasyPlot.Waveform)
	return _add(g, wfrm.data, _graceline(wfrm), _graceglyph(wfrm), id=wfrm.id)
end

#Add a waveform to an eye diagram:
function _add(g::GracePlot.GraphRef, wfrm::EasyPlot.Waveform, param::EasyPlot.EyeAttributes)
	eye = EasyPlot.BuildEye(wfrm.data, param.tbit, param.teye, tstart=param.tstart)
	return _add(g, eye, _graceline(wfrm), _graceglyph(wfrm), id=wfrm.id)
end

#Render a paraticular subplot:
function _render(g::GracePlot.GraphRef, subplot::EasyPlot.Subplot, displaylegend::Bool)
	set(g, subtitle = subplot.title)

	if :eye == subplot.style
		ep = subplot.eye
		if nothing == ep.teye; ep.teye = ep.tbit; end
		for wfrm in subplot.wfrmlist
			_add(g, wfrm, ep)
		end
	else
		for wfrm in subplot.wfrmlist
			_add(g, wfrm)
		end
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
		_render(g, s, eplot.displaylegend)
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
