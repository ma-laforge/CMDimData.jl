#Demo 1: Saving/loading multi-dimensional datasets
#-------------------------------------------------------------------------------

using FileIO2
using MDDatasets
using EasyPlot
using EasyData


#==Constants
===============================================================================#
vvst = axes(xlabel="Time (s)", ylabel="Amplitude (V)")
color1 = line(color=2)
color2 = line(color=3)
color3 = line(color=4)


#==Input data
===============================================================================#
tfund = 1e-9 #Fundamental
osr = 20 #(fundamental) oversampling ratio
nfund = 20 #cycles of the fundamenal


#==Computations
===============================================================================#
t = DataF1(0:(tfund/osr):(nfund*tfund))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("period", [1,2,3]*tfund)
	PSweep("slope", [-1,0,1]*(.5/tmax))
	PSweep("offset", [-.4, 0, .9])
]

#Generate data:
lines = DataHR{DataF1}(sweeplist) #Create empty dataset
tones = DataHR{DataF1}(sweeplist) #Create empty dataset
for inds in subscripts(lines)
	(T, m, b) = coordinates(lines, inds)
	lines.elem[inds...] = DataF1(t.x, (x)->m*x+b)
	tones.elem[inds...] = sin(t*(2pi/T))
end


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Mulit-Dataset Tests")
	plot.displaylegend=false #Too busy with GracePlot
s = add(plot, vvst, title="Lines")
	add(s, lines, id="")
#Plot reduced dataset:
s = add(plot, vvst, title="maximum(Lines)")
	add(s, maximum(lines), glyph(shape=:o), id="")
s = add(plot, vvst, title="Tones")
	add(s, tones, id="")
s = add(plot, vvst, title="Sum")
	add(s, lines+tones, id="")

#throw("STOP")
file = File(:edh5, "./sampleplot1.hdf5")
write(file, plot)
plot2=read(file)[1]; #Returns array of plots
set(plot2, title="Compare results")

#==Show results
===============================================================================#
ncols = 1
if !isdefined(:plotlist); plotlist = Set([:grace]); end
if in(:grace, plotlist)
	import EasyPlotGrace
	plotdefaults = GracePlot.defaults(linewidth=2.5)
	gplot = GracePlot.new()
		GracePlot.set(gplot, plotdefaults)
	render(gplot, plot, ncols=ncols); display(gplot)
	gplot = GracePlot.new()
		GracePlot.set(gplot, plotdefaults)
	render(gplot, plot2, ncols=ncols); display(gplot)
end
if in(:MPL, plotlist)
	import EasyPlotMPL
	display(:MPL, plot, ncols=ncols);
	display(:MPL, plot2, ncols=ncols);
end


:Test_Complete
