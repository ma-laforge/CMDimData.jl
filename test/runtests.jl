#Test code
#-------------------------------------------------------------------------------

using EasyPlot 
using MDDatasets

#No real test code yet... just run demos:

const separator = "-----------------------------"

x=[1:10]
@show d1 = Data2D(x, x.^2)

println("\n", separator)
dfltline = line(style=:solid, color=:red)
dfltglyph = glyph(shape=:square, size=3)
axes_loglin = axes(xscale = :log, yscale = :lin)
@show dfltline
@show dfltglyph

plot = EasyPlot.new(title = "Sample Plot")
subplot = add(plot, axes_loglin, title = "Subplot 1")
wfrm = add(subplot, d1, id="Quadratic")

println("\n", separator)
@show wfrm
set(wfrm, dfltline, dfltglyph)
println("\n", separator)
@show plot
println("\n", separator)
@show wfrm

:Test_Complete
