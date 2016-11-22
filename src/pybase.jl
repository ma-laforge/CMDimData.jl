#EasyPlotQwt: Python wrappers for base types & core functions
#-------------------------------------------------------------------------------

import PyCall
import PyCall: @pyimport, PyObject

@pyimport guiqwt.pyplot as QwtPyPlot
@pyimport guiqwt.builder as QwtBuilder

PyCall.pygui_start(:qt_pyqt4) #Runs Qt application thread in background?


#==Wrapper types
===============================================================================#
type Figure
	o::PyObject
	function Figure(args...; kwargs...)
		fig = QwtPyPlot.figure(args...; kwargs...)
		return new(fig)
	end
end

type Axes
	o::PyObject
	function Axes(fig::Figure, row::Int, col::Int)
		return new(fig.o[:get_axes](row, col))
	end
end

type Curve
	o::PyObject
	function Curve(args...; kwargs...)
		return new(QwtBuilder.make[:curve](args...; kwargs...))
		#Poor control of curve attributes:
#		return new(QwtBuilder.make[:mcurve](args...; kwargs...))
	end
end


#==Wrapper functions
===============================================================================#

#Relay get/set interface to python object:
const _qwtpltobjects = [:Figure, :Axes, :Curve]
for objType in _qwtpltobjects; @eval begin #CODEGEN-----------------------------

Base.getindex(o::$objType, k::Symbol) = o.o[k]
Base.setindex!(o::$objType, v, k::Symbol) = (o.o[k] = v)

end; end #CODEGEN---------------------------------------------------------------

#mxn matrix @ pos
function subplot(fig::Figure, m::Int, n::Int, pos::Int)
	row = div(pos-1,n)
	col = (pos-1)%n
	return Axes(fig, row, col)
end

function _save(fig::Figure, filepath::String, format::String; draft::Bool=false)
	format = lowercase(format)
	fig[:save](filepath, format, draft)
end

#Add interface:
#-------------------------------------------------------------------------------
add(ax::Axes, s::Symbol, args...; kwargs...) = add(ax, DS(s), args...; kwargs...)


function add(ax::Axes, c::Curve, args...; kwargs...)
	ax[:add_plot](c.o, args...; kwargs...)
end

#pos ∈ TR/TL/BR/BL
function add(ax::Axes, ::DS{:legend}, pos="TR")
    ax[:add_legend](pos)
end

#Last line
