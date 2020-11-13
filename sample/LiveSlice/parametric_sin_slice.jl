#"Live-Slice" the results of a parametric sinusoidal "simulation
#-------------------------------------------------------------------------------
module CMDimData_SampleDemo

using CMDimData
using CMDimData.EasyPlot
using MDDatasets
import InspectDR
CMDimData.@includepkg EasyPlotInspect

pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
LBL_AXIS_TIME = "Time (s)"
LBL_AXIS_POSITION = "Position (m)"
LBL_AXIS_NORMPOSITION = "Normalized Pos (m/m)"
LBL_AXIS_SPEED = "Speed (m/s)"
lstylesweep = cons(:a, line = set(style=:solid, width=2)) #Default is a bit thin
dfltglyph = cons(:a, glyph = set(shape=:o, size=1.5))


#==Read in results of parametric "simulation"
===============================================================================#
signal = evalfile("../parametric_sin_data.jl")
signal = convert(DataHR, signal) #Need DataHR for Live-Slice


#==Parameter extraction
===============================================================================#

#Generate DataRS with value of amplitude (A) in each parameter combination:
ampvalue = parameter(signal, "A")

#Normalize signal amplitudes for ALL signals SIMULTANEOUSLY:
signal_norm = signal / ampvalue

#Compute continuous-time signal rate for ALL signals SIMULTANEOUSLY:
#   signal(𝜙, A, 𝑓, t) -> rate(𝜙, A, 𝑓):
rate = deriv(signal)

#Compute maximum signal rate for ALL signals SIMULTANEOUSLY:
maxrate = maximum(abs(rate))

#Compute first fall-crossing point for ALL signals SIMULTANEOUSLY:
#   signal(𝜙, A, 𝑓, t) -> fallx(𝜙, A, 𝑓):
fallx = xcross1(signal, xstart=0, allow=CrossType(:fall))


#==Generate plots
===============================================================================#
xred1 = paramlist(fallx)[end] #x-value of 1st reduction operation (finding 1st-xing time)
#Fixed yaxis values to place results in better context:
yext_pos = (min=-5e-3, max=5e-3)
yext_speed = (min=-400, max=400)
yext_firstx = (min=0, max=800e-6)
yext_maxrate = (min=0, max=500)

#plot #1: Complete time-domain signals
#-------------------------------------------------------------------------------
p1 = cons(:plot, nstrips = 3,
	ystrip1 = set(axislabel=LBL_AXIS_POSITION, striplabel="Sinusoidal response"; yext_pos...),
	ystrip2 = set(axislabel=LBL_AXIS_NORMPOSITION, striplabel="Normalized response"),
	ystrip3 = set(axislabel=LBL_AXIS_SPEED, striplabel="Rate of change"; yext_speed...),
	xaxis = set(label=LBL_AXIS_TIME)
)
push!(p1,
	cons(:wfrm, signal, lstylesweep, label="", strip=1),
	cons(:wfrm, signal_norm, lstylesweep, label="", strip=2),
	cons(:wfrm, rate, lstylesweep, label="", strip=3),
)

#plot #2: Extracted parameter values: fallx, maxrate
#-------------------------------------------------------------------------------
p2 = cons(:plot, nstrips = 2, legend=false,
	ystrip1 = set(axislabel=LBL_AXIS_TIME, striplabel="Time to 1st fall-crossing"; yext_firstx...),
	ystrip2 = set(axislabel=LBL_AXIS_SPEED, striplabel="Maximum signal rate"; yext_maxrate...),
	xaxis = set(label=xred1),
)
push!(p2,
	cons(:wfrm, fallx, lstylesweep, dfltglyph, label="", strip=1),
	cons(:wfrm, maxrate, lstylesweep, dfltglyph, label="", strip=2),
)

println()
@info("Displaying plot...")
pcoll = cons(:plotcoll, title="Parametric sin() - Live-Slice Results", ncolumns=2)
	push!(pcoll, p1, p2)
gplot = display(pdisp, pcoll)

#Activate Live-Slice GUI:
println()
@info("Activating Live-Slice GUI...")
include("tools/liveslice_blink.jl")
slicelist = sweeps(fallx)[1:end-1] #Use 2 first dimensions for slice
wfrmlist = append!(append!(EasyPlot.Waveform[], p1.wfrmlist), p2.wfrmlist)
LiveSlice.autoslice(slicelist, wfrmlist) do
	EasyPlot.render(gplot.src, pcoll)
	InspectDR.refresh(gplot)
end

end #module
