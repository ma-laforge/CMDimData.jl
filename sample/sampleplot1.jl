#EasyPlot sampleplot1: A simple plot
#-------------------------------------------------------------------------------

using EasyPlot
using MDDatasets

#==Constants
===============================================================================#
const linlin = axes(xscale = :lin, yscale = :lin)
const alabels = axes(xlabel="X-Axis Label", ylabel="X-Axis Label")

#Defaults
#-------------------------------------------------------------------------------
dfltline = line(style=:solid, color=:red)
dfltglyph = glyph(shape=:square, size=3)


#==Input data
===============================================================================#
x = collect(-2:0.01:2)
graph = Data2D[]
for _exp in 0:3
	push!(graph, Data2D(x, x.^_exp))
end


#==Generate EasyPlot
===============================================================================#
plot = EasyPlot.new(title = "Sample Plot")
subplot = add(plot, linlin, alabels, title = "Polynomial Equations")
	add(subplot, graph[1], id="Constant")
	add(subplot, graph[2], id="Linear")
	add(subplot, graph[3], id="Quadratic")
	wfrm = add(subplot, graph[4], id="Cubic")
		set(wfrm, dfltline, dfltglyph)


#==Return plot to user (call evalfile(...))
===============================================================================#
plot

#Last line
