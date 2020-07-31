#Demo 1: A simple plot
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.EasyPlot
using CMDimData.MDDatasets


#==Attributes
===============================================================================#
linlin = cons(:a, xyaxes=set(xscale=:lin, yscale=:lin))
alabels = cons(:a, labels=set(xaxis="X-Axis Label", yaxis="Y-Axis Label"))
dfltline = cons(:a, line=set(style=:solid, color=:red))
dfltglyph = cons(:a, glyph=set(shape=:square, size=3))


#==Input data
===============================================================================#
x = collect(-2:0.01:2)
graph = DataF1[]
for _exp in 0:3
	push!(graph, DataF1(x, x.^_exp))
end


#==Generate EasyPlot
===============================================================================#
plot = push!(cons(:plot, linlin, alabels, title = "Polynomial Equations"),
	cons(:wfrm, graph[1], label="Constant"),
	cons(:wfrm, graph[2], label="Linear"),
	cons(:wfrm, graph[3], label="Quadratic"),
)

#Create individual waveform, and set parameters later:
wfrm = cons(:wfrm, graph[4], label="Cubic")
	set(wfrm, dfltline, dfltglyph)
push!(plot, wfrm) #Now add it to the list of plots

pcoll = push!(cons(:plot_collection, title="Sample Plot"), plot)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
