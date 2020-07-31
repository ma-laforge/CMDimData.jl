#Demo 5: Generating DataRS & DataHR Datsets
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot


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
plot1 = push!(cons(:plot, vvst, title="DataHR"),
	cons(:wfrm, tonesHR, label="tones"),
)
plot2 = push!(cons(:plot, vvst, title="DataRS"),
	cons(:wfrm, tonesRS, label="tones"),
)

pcoll = push!(cons(:plot_collection, title="DataHR & DataMD"), plot1, plot2)
	pcoll.displaylegend = true
	pcoll.ncolumns = 1


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
