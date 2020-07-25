#Demo 1: A full calculation/plotting example using EasyPlotInspect
#-------------------------------------------------------------------------------
module CMDimData_SampleDemo

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotInspect
CMDimData.@includepkg EasyData


#==Constants
===============================================================================#
pvst = paxes(xlabel="Time (s)", ylabel="Position (m)")
lstylesweep = line(width=3)
lstyle1 = line(color=:red, width=3, style=:solid)
lstyle2 = line(color=:blue, width=3)


#==Input data
===============================================================================#
x = DataF1(0:.1:20)
#NOTE: Both x & y coordinates of "x" object initialized as y = x = [supplied range]


#==Computations
===============================================================================#
#“Extract” maximum x-value from data:
xmax = maximum(x)

#Construct a “normalized” ramp dataset, unity_ramp:
unity_ramp = x/xmax

#Compute sin(x)
sinx = sin(x)

#Compute ramps with different slopes using unity_ramp (previously computed):
#NOTE: for Inner-most sweep, we need to specify leaf element type (DataF1 here):
ramp = fill(DataRS{DataF1}, PSweep("slope", [0, 0.5, 1, 1.5, 2])) do slope
	return unity_ramp * slope
end

#Merge two datasets with different # of sweeps (sinx & ramp):
r_sin = sinx+ramp

#Shift all ramped sin(x) waveforms to make them centered at their mid-points:
midval = (minimum(ramp) + maximum(ramp)) / 2

#Shift by midval (different for each swept slope of "ramp"):
c_sin = r_sin - midval


#==Generate plot
===============================================================================#
plot=EasyPlot.new(title="Demo 1 EasyPlot (InspectDR)")
	plot.displaylegend=true
s = add(plot, pvst, title="Subplot: Building blocks")
	add(s, unity_ramp, lstyle1, id="Unity Ramp")
	add(s, sinx, lstyle2, id="sin(x)")
s = add(plot, pvst, title="Subplot: Ramp with swept \"slope\"")
	add(s, ramp, lstylesweep, id="swept ramp")
s = add(plot, pvst, title="Subplot: sin(x) + ramp")
	add(s, r_sin, lstylesweep, id="r_sin")
s = add(plot, pvst, title="Subplot: sin(x) + ramp - midval")
	add(s, c_sin, lstylesweep, id="r_sin")
plot.ncolumns = 1

	#Save plot for later use:
	filename = basename(@__FILE__)
	savefile = joinpath("./", splitext(filename)[1] * ".hdf5")
	EasyData._write(savefile, plot)

	#Display plot:
	pdisp = EasyPlotInspect.PlotDisplay()
	display(pdisp, plot)
	return plot
end
