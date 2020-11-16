#Demo 1: A full calculation/plotting example using EasyPlotInspect
#-------------------------------------------------------------------------------
module CMDimData_SampleUsage

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotInspect
CMDimData.@includepkg EasyData


#==Constants
===============================================================================#
LBLAX_POS = "Position [m]"
LBLAX_TIME = "Time [s]"
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
plot = cons(:plot, nstrips=4,
	ystrip1 = set(axislabel=LBLAX_POS, striplabel="Plot: Building blocks"),
	ystrip2 = set(axislabel=LBLAX_POS, striplabel="Plot: Ramp with swept \"slope\""),
	ystrip3 = set(axislabel=LBLAX_POS, striplabel="Plot: sin(x) + ramp"),
	ystrip4 = set(axislabel=LBLAX_POS, striplabel="Plot: sin(x) + ramp - midval"),
	xaxis = set(label=LBLAX_TIME),
)

push!(plot,
	cons(:wfrm, unity_ramp, lstyle1, label="Unity Ramp", strip=1),
	cons(:wfrm, sinx, lstyle2, label="sin(x)", strip=1),
	cons(:wfrm, ramp, lstylesweep, label="swept ramp", strip=2),
	cons(:wfrm, r_sin, lstylesweep, label="r_sin", strip=3),
	cons(:wfrm, c_sin, lstylesweep, label="r_sin", strip=4),
)

pcoll = cons(:plot_collection, title="Demo 1 EasyPlot (InspectDR)", ncolumns=1)
	push!(pcoll, plot)

	#Save pcoll for later use:
	filename = basename(@__FILE__)
	savefile = joinpath("./", splitext(filename)[1] * ".hdf5")
	EasyData.writeplot(savefile, pcoll)

	#Display pcoll:
	EasyPlot.displaygui(:InspectDR, pcoll)
	savefile = joinpath("./", splitext(filename)[1] * ".png")
	EasyPlot._write(:png, savefile, :InspectDR, pcoll)
end #module
:SampleCode_Executed
