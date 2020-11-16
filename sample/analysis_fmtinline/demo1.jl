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
pvst = cons(:a, labels = set(xaxis="Time (s)", yaxis="Position (m)"))
lstylesweep = cons(:a, line = set(width=3))
lstyle1 = cons(:a, line = set(color=:red, width=3, style=:solid))
lstyle2 = cons(:a, line = set(color=:blue, width=3))


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
plt1 = push!(cons(:plot, pvst, title="Plot: Building blocks"),
	cons(:wfrm, unity_ramp, lstyle1, label="Unity Ramp"),
	cons(:wfrm, sinx, lstyle2, label="sin(x)"),
)
plt2 = push!(cons(:plot, pvst, title="Plot: Ramp with swept \"slope\""),
	cons(:wfrm, ramp, lstylesweep, label="swept ramp"),
)
plt3 = push!(cons(:plot, pvst, title="Plot: sin(x) + ramp"),
	cons(:wfrm, r_sin, lstylesweep, label="r_sin"),
)
plt4 = push!(cons(:plot, pvst, title="Plot: sin(x) + ramp - midval"),
	cons(:wfrm, c_sin, lstylesweep, label="r_sin"),
)

pcoll = cons(:plot_collection, title="Demo 1 EasyPlot (InspectDR)", ncolumns=1)
	push!(pcoll, plt1, plt2, plt3, plt4)

	#Save pcoll for later use:
	filename = basename(@__FILE__)
	savefile = joinpath("./", splitext(filename)[1] * ".hdf5")
	EasyData.writeplot(savefile, pcoll)

	#Display pcoll:
	pdisp = EasyPlotInspect.PlotDisplay()
	display(pdisp, pcoll)
end
