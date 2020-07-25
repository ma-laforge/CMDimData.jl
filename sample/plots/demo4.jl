#Demo 4: Multi-dimensional datasets (advanced usage)
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
import Printf: @sprintf


#==Constants
===============================================================================#
vvst = paxes(xlabel="Time (s)", ylabel="Amplitude (V)")
color1 = line(color=2)
color2 = line(color=3)
color3 = line(color=4)


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
plot=EasyPlot.new(title="Mulit-Dataset Tests: Subarrays")
	plot.displaylegend=false #Too busy with GracePlot
s = add(plot, vvst, title="Tones") #Create subplot
	add(s, tones, id="")
s = add(plot, vvst, title="Tones ($(strns(2tfund)))")
	add(s, tones_2T, id="")
s = add(plot, vvst, title="Tones ($(strns(3tfund)))")
	add(s, tones_3T, id="")
s = add(plot, vvst, title="Tones (increasing slope)")
	add(s, tones_incm, id="")
plot.ncolumns = 1


#==Return plot to user (call evalfile(...))
===============================================================================#
plot
