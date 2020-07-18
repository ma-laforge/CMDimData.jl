#Demo 5: Generating DataRS & DataHR Datsets
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot


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
nfund = 20 #cycles of the fundamenal


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
plot=EasyPlot.new(title="DataHR & DataMD")
	plot.displaylegend=true #Too busy with GracePlot
s = add(plot, vvst, title="DataHR")
	add(s, tonesHR, id="tones")
s = add(plot, vvst, title="DataRS")
	add(s, tonesRS, id="tones")
plot.ncolumns = 1


#==Return plot to user (call evalfile(...))
===============================================================================#
plot
