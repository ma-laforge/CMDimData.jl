#EasyPlotGrace demonstration 1: A simple plot
#-------------------------------------------------------------------------------

using EasyPlotGrace
using EasyPlot
using MDDatasets

#==Constants
===============================================================================#
const separator = "-----------------------------"
const engpaper=GracePlot.template("engpaper_mono")
const loglin = axes(xscale = :log, yscale = :lin)
const linlin = axes(xscale = :lin, yscale = :lin)

#Defaults
#-------------------------------------------------------------------------------
dfltline = line(style=:solid, color=:red)
dfltglyph = glyph(shape=:square, size=3)


#==Input data
===============================================================================#
x = [-2:0.01:2]

y = Data2D[]
for _exp in 0:3
	push!(y, Data2D(x, x.^_exp))
end


#==Generate EasyPlot
===============================================================================#
plot = EasyPlot.new(title = "Sample Plot")
subplot = add(plot, linlin, title = "Polynomial Equations")
	set(subplot, axes(xlabel="X-Axis Label", ylabel="X-Axis Label"))
	add(subplot, y[1], id="Constant")
	add(subplot, y[2], id="Linear")
	add(subplot, y[3], id="Quadratic")
	wfrm = add(subplot, y[4], id="Cubic")
		set(wfrm, dfltline, dfltglyph)

#==Render EasyPlot
===============================================================================#
#display(Backend{:Grace}, plot, template=engpaper)
display(Backend{:Grace}, plot)

#Last line
