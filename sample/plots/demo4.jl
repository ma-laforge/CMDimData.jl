#Demo 4: Multi-dimensional datasets (advanced usage)
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
import Printf: @sprintf


#==Attributes
===============================================================================#
vvst = cons(:a, labels = set(xaxis="Time (s)", yaxis="Amplitude (V)"))


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

tones += lines #Create shifted dataset
#Filter on 2T harmonic:
tones_2T = getsubarray(tones, period=2tfund)
#Filter on 3T harmonic:
tones_3T = getsubarray(tones, period=3tfund)
#Filter on increasing slope (3rd index):
tones_incm = getsubarray(tones, :,3,:)


#==Generate plot
===============================================================================#
strns(T) = @sprintf("%.1f ns", T/1e-9)

plot1 = push!(cons(:plot, vvst, title="Tones"),
	cons(:wfrm, tones, label=""),
)
plot2 = push!(cons(:plot, vvst, title="Tones ($(strns(2tfund)))"),
	cons(:wfrm, tones_2T, label=""),
)
plot3 = push!(cons(:plot, vvst, title="Tones ($(strns(3tfund)))"),
	cons(:wfrm, tones_3T, label=""),
)
plot4 = push!(cons(:plot, vvst, title="Tones (increasing slope)"),
	cons(:wfrm, tones_incm, label=""),
)

pcoll = push!(cons(:plot_collection, title="Mulit-Dataset Tests: Subarrays"), plot1, plot2, plot3, plot4)
	pcoll.displaylegend=false #Too busy with GracePlot
	pcoll.ncolumns=1


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
