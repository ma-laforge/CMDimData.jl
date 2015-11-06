#Test code
#-------------------------------------------------------------------------------

using EasyPlot 
using MDDatasets
using FileIO2

#No real test code yet... just run demos:

function printsep()
	const separator = "\n-----------------------------"
	println(separator)
end

x=collect(1:10)
@show d1 = Data2D(x, x.^2)

printsep()
	dfltline = line(style=:solid, color=:red)
	dfltglyph = glyph(shape=:square, size=3)
	axes_loglin = axes(xscale = :log, yscale = :lin)
	@show dfltline
	@show dfltglyph

	plot = EasyPlot.new(title = "Sample Plot")
	subplot = add(plot, axes_loglin, title = "Subplot 1")
	wfrm = add(subplot, d1, id="Quadratic")

printsep()
	@show wfrm
	set(wfrm, dfltline, dfltglyph)
printsep()
	@show plot
printsep()
	@show wfrm

for i in 1:1
	printsep()
	@show p=evalfile(EasyPlot.sampleplotfile(1));
end

:Test_Complete
