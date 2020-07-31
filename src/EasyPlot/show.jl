#EasyPlot: show functions
#-------------------------------------------------------------------------------

const SHOW_INDENTSTR = "   "

Base.show(io::IO, ::Axis{T}) where T = print(io, "Axis{$T}")

showcompact_lengthinfo(io::IO, d) = print(io, typeof(d))
showcompact_lengthinfo(io::IO, d::DataF1) = print(io, "DataF1: ", length(d), "pts")
showcompact_lengthinfo(io::IO, d::DataRS) = print(io, "DataRS:", paramlist(d))
showcompact_lengthinfo(io::IO, d::DataHR) = print(io, "DataHR:", String[s.id for s in d.sweeps])

function showshorthand(io::IO, wfrm::Waveform)
	print(io, "Waveform(")
	show(io, wfrm.label) #With "quotes"
	print(io, ", ")
	showcompact_lengthinfo(io, wfrm.data)
	print(io, ")")
end

function showindented(io::IO, p::Plot, indent::String)
	xaxis = p.xaxis
	print(io, indent, "Plot(")
	show(io, p.title) #With "quotes"
	print(io, ", $xaxis, [")
	rmg = length(p.ystriplist)
	for strip in p.ystriplist
		scale = strip.scale
		print(io, scale)
		rmg -= 1
		rmg > 0 ? print(io, ", ") : nothing
	end
	print(io, "])[\n")
	wfrmindent = indent * SHOW_INDENTSTR
	for wfrm in p.wfrmlist
		print(io, wfrmindent); showshorthand(io, wfrm); println(io)
	end
	print(io, indent, "]")
end

Base.show(io::IO, p::Plot) = showindented(io, p, "")

function Base.show(io::IO, pc::PlotCollection)
	print(io, "PlotCollection(")
	show(io, pc.title) #With "quotes"
	print(io, ")[\n")
	for p in pc.plotlist
		showindented(io, p, SHOW_INDENTSTR); println(io)
	end
	print(io, "]")
end

#Show dispatchable symbols more succinctly (Errors easier to debug)
Base.show(io::IO, t::Type{DS}) = print(io, "DS")
function Base.show(io::IO, t::Type{DS{DT}}) where DT
	sym = @isdefined(DT) ? DT : :T #Used in declarations like: cons(::DT{T}, ...) where T
	print(io, "DS{$sym}")
end

#Last line
