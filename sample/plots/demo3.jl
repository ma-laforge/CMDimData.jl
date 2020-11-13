#Demo 3: Plotting multi-dimensional datasets
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot


#==Attributes
===============================================================================#
vvst = cons(:a, labels = set(xaxis="Time (s)", yaxis="Amplitude (V)"))
lcolor1 = cons(:a, line = set(color=2)) #Example: ordinal color selection


#==Input data
===============================================================================#
tfund = 1e-9 #Fundamental
osr = 20 #(fundamental) oversampling ratio
nfund = 20 #cycles of the fundamental


#==Computations
===============================================================================#
t = DataF1(0:(tfund/osr):(nfund*tfund))
tmax = maximum(t)

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("period", [1,2,3]*tfund)
	PSweep("slope", [-1,0,1]*(1/tmax))
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
_legend = false #Too busy with GracePlot
plot1 = push!(cons(:plot, vvst, title="Lines", legend=_legend),
	cons(:wfrm, lines),
)
#Plot reduced dataset:
plot2 = push!(cons(:plot, vvst, title="maximum(Lines)", legend=_legend),
	cons(:wfrm, maximum(lines), line=set(style=:solid), glyph=set(shape=:o)),
)
plot3 = push!(cons(:plot, vvst, title="Tones", legend=_legend),
	cons(:wfrm, tones),
)
plot4 = push!(cons(:plot, vvst, title="Sum", legend=_legend),
	cons(:wfrm, lines+tones),
)

pcoll = cons(:plot_collection, title="Multi-Dataset Tests")
	push!(pcoll, plot1, plot2, plot3, plot4)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
