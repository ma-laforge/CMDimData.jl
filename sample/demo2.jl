#Demo 2: Multi-dimensional datasets (advanced usage)
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
for coord in subscripts(lines)
	(T, m, b) = parameter(lines, coord)
	lines.subsets[coord...] = DataF1(t.x, (x)->m*x+b)
	tones.subsets[coord...] = sin(t*(2pi/T))
end

tones += lines #Create shifted dataset

#==Generate plot
===============================================================================#
strns(T) = @sprintf("%.1f ns", T/1e-9)
plot=EasyPlot.new(title="Mulit-Dataset Tests")
	plot.displaylegend=false #Too busy with GracePlot
s = add(plot, vvst, title="Tones")
	add(s, tones, id="")
#Filter 2nd harmonic:
s = add(plot, vvst, title="Tones ($(strns(2tfund)))")
	add(s, sub(tones, period=2tfund), id="")
s = add(plot, vvst, title="Tones ($(strns(3tfund)))")
	add(s, sub(tones, period=3tfund), id="")
#Filter slope:
s = add(plot, vvst, title="Tones (increasing slope)")
	add(s, sub(tones, :,3,:), id="")
#throw("STOP")

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
end
if in(:MPL, plotlist)
	import EasyPlotMPL
	display(Backend{:MPL}, plot, ncols=ncols);
end


:Test_Complete
