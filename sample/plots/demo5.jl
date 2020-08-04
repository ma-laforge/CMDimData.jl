#Demo 5: Generating DataRS & DataHR Datsets
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot


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

#Generate parameter sweeps:
sweeplist = PSweep[
	PSweep("period", [1,2,3]*tfund)
	PSweep("amp", [1, 1.5, 2])
]

#Generate data:
tonesHR = fill(DataHR{DataF1}, sweeplist) do T, amp
	return amp*sin(t*(2pi/T))
end

tonesRS = DataRS(tonesHR)


#==Generate plot
===============================================================================#
plot = cons(:plot, nstrips=2,
	ystrip1 = set(axislabel=LBL_AXIS_AMPLITUDE, striplabel="DataHR"),
	ystrip2 = set(axislabel=LBL_AXIS_AMPLITUDE, striplabel="DataRS"),
	xaxis = set(label=LBL_AXIS_TIME),
)
push!(plot,
	cons(:wfrm, tonesHR, label="tones", strip=1),
	cons(:wfrm, tonesRS, label="tones", strip=2),
)

pcoll = push!(cons(:plot_collection, title="DataHR & DataMD"), plot)
	pcoll.displaylegend = true
	pcoll.ncolumns = 1


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
