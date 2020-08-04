#Demo 4: Multi-dimensional datasets (advanced usage)
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
import Printf: @sprintf


#==Attributes
===============================================================================#
LBL_AXIS_TIME = "Time (s)"
LBL_AXIS_AMPLITUDE = "Amplitude"


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
strns(T) = @sprintf("%.1f ns", T/1e-9) #Generate string with # of ns from supplied value

plot = cons(:plot, nstrips=4,
	ystrip1 = set(axislabel=LBL_AXIS_AMPLITUDE, striplabel="Tones"),
	ystrip2 = set(axislabel=LBL_AXIS_AMPLITUDE, striplabel="Tones ($(strns(2tfund)))"),
	ystrip3 = set(axislabel=LBL_AXIS_AMPLITUDE, striplabel="Tones ($(strns(3tfund)))"),
	ystrip4 = set(axislabel=LBL_AXIS_AMPLITUDE, striplabel="Tones (increasing slope)"),
	xaxis = set(label=LBL_AXIS_TIME),
)
push!(plot,
	cons(:wfrm, tones, strip=1),
	cons(:wfrm, tones_2T, strip=2),
	cons(:wfrm, tones_3T, strip=3),
	cons(:wfrm, tones_incm, strip=4),
)

pcoll = push!(cons(:plot_collection, title="Mulit-Dataset Tests: Subarrays"), plot)
	pcoll.displaylegend=false #Too busy with GracePlot
	pcoll.ncolumns=1


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
