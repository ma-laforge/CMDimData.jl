#Parametric sinusoidal "simulation" & parameter extraction
#-------------------------------------------------------------------------------
module CMDimData_SampleDemo

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotInspect
pdisp = EasyPlotInspect.PlotDisplay()


#==Constants
===============================================================================#
const π = MathConstants.π
LBL_AXIS_TIME = "Time (s)"
LBL_AXIS_POSITION = "Position (m)"
LBL_AXIS_NORMPOSITION = "Normalized Pos (m/m)"
LBL_AXIS_SPEED = "Speed (m/s)"
pvst = cons(:a, labels = set(xaxis="Time (s)", yaxis="Position (m)"))
rvst = cons(:a, labels = set(xaxis="Time (s)", yaxis="Rate (m/s)"))
lstylesweep = cons(:a, line = set(style=:solid, width=2)) #Default is a bit thin
lstyle1 = cons(:a, line = set(color=:red, width=2, style=:solid))
lstyle2 = cons(:a, line = set(color=:blue, width=2))
dfltglyph = cons(:a, glyph = set(shape=:o, size=1.5))


#==Emulate reading in simulated data file
===============================================================================#

#=COMMENT
The code below emulates a parametric "simulation" of a sinusoidal response where
the 𝑓, 𝜙, and A parameters of `signal = A * sin(𝜔*t + 𝜙); 𝜔 = 2π*𝑓` are varied.

The parametric signal can therefore be fully represented as:
	signal(𝑓, 𝜙, A, t)
=#

#But really construct multidimensional DataRS dataset manually:
signal = fill(DataRS, PSweep("A", [1, 2, 4] .* 1e-3)) do A
	fill(DataRS, PSweep("phi", [0, 0.5, 1] .* (π/4))) do 𝜙
	#Inner-most sweep: need to specify element type (DataF1):
	#(Other (scalar) element types: DataInt/DataFloat/DataComplex)
	fill(DataRS{DataF1}, PSweep("freq", [1, 4, 16] .* 1e3)) do 𝑓
		𝜔 = 2π*𝑓
		T = 1/𝑓
		Δt = T/100 #Define resolution from # of samples per period
		Tsim = 4T #Simulated time

		t = DataF1(0:Δt:Tsim) #DataF1 creates a t:{y, x} container with y == x
		sig = A * sin(𝜔*t + 𝜙) #Still a DataF1 sig:{y, x=t} container
		return sig
end; end; end


#==Helper functions
===============================================================================#
function savepng(pdisp, pcoll, filepath::String)
	#render() instead of display(), thus allowing settings to be tweaked
	rplot = render(pdisp, pcoll)
	rplot.layout[:halloc_plot] = rplot.layout[:halloc_plot] * 1.5
	rplot.layout[:valloc_plot] = rplot.layout[:halloc_plot] * .3
		for sp in rplot.subplots
			sp.layout[:halloc_legend] = 300
		end
		EasyPlotInspect.InspectDR.write_png(filepath, rplot)
end


#==Parameter extraction
===============================================================================#
println()
@info("Information on `signal`:")
@show psweep_depth = ndims(signal)
@show psweep_names = paramlist(signal)
@show xparam = paramlist(signal)[end]

#Generate DataRS with value of amplitude (A) in each parameter combination:
ampvalue = parameter(signal, "A")

signal_norm = signal / ampvalue

#Compute rate of signal:
rate = deriv(signal)

#Find peak value of rate, thus collapsing inner-most sweep
#   rate(A, 𝜙, 𝑓, t) -> maxrate(A, 𝜙, 𝑓):
maxrate = maximum(rate)

#Compute 1st falling crossing point of signal, thus collapsing inner-most sweep:
#   signal(A, 𝜙, 𝑓, t) -> fallx(A, 𝜙, 𝑓):
fallx = xcross1(signal, xstart=0, allow=CrossType(:fall))

println()
@info("Evaluate `fallx` @ 4kHz (`fallx_at4k`) to test parameter reduction:")
#   fallx(A, 𝜙, 𝑓) -> fallx_at4k(A, 𝜙):
fallx_at4k = value(fallx, x=4e3)
@show ndims(fallx_at4k)
@show xparam_reduce1 = paramlist(fallx_at4k)[end]

println()
@info("Evaluate `fallx_at4k` @ {4kHz, phi=0} (`fallx_at4kphi0`) to test parameter reduction:")
#   fallx_at4k(A, 𝜙) -> fallx_at4kphi0(A):
fallx_at4kphi0 = value(fallx_at4k, x=0)
fallx_at4kphiπ_4 = value(fallx_at4k, x=(π/4))
@show ndims(fallx_at4kphi0)
@show xparam_reduce2 = paramlist(fallx_at4kphi0)[end]


#==Generate plots
===============================================================================#

#1st plot set: Parametric sin(): Initial observations
#-------------------------------------------------------------------------------
plot = cons(:plot, nstrips = 3,
	ystrip1 = set(axislabel=LBL_AXIS_POSITION, striplabel="Sinusoidal response"),
	ystrip2 = set(axislabel=LBL_AXIS_NORMPOSITION, striplabel="Normalized response (All peaks should be ±1)"),
	ystrip3 = set(axislabel=LBL_AXIS_SPEED, striplabel="Rate of change (should be larger for higher frequencies)"),
	xaxis = set(label=LBL_AXIS_TIME)
)
push!(plot,
	cons(:wfrm, signal, lstylesweep, label="signal", strip=1),
	cons(:wfrm, signal_norm, lstylesweep, label="signal_norm", strip=2),
	cons(:wfrm, rate, lstylesweep, label="rate", strip=3),
)
pcoll = push!(cons(:plotcoll, title="Parametric sin() - Initial Observations"), plot)
	pcoll.displaylegend=true
display(pdisp, pcoll)
	savepng(pdisp, pcoll, "parametric_sin_1.png")


#2nd plot set: Parametric sin(): Discovering Trends
#-------------------------------------------------------------------------------
plot = cons(:plot, nstrips = 2,
	ystrip1 = set(axislabel=LBL_AXIS_SPEED, striplabel="Maximum rate of signal (should increase with $xparam)"),
	ystrip2 = set(axislabel=LBL_AXIS_TIME, striplabel="Time to 1st falling crossing (should decrease with $xparam)"), #; yext_firstx...),
	xaxis = set(label=xparam)
)
push!(plot,
	cons(:wfrm, maxrate, lstylesweep, dfltglyph, label="maxrate", strip=1),
	cons(:wfrm, fallx, lstylesweep, dfltglyph, label="fallx", strip=2),
)
pcoll = push!(cons(:plotcoll, title="Parametric sin() - Discovering Trends"), plot)
	pcoll.displaylegend=true
display(pdisp, pcoll)
	savepng(pdisp, pcoll, "parametric_sin_2.png")


#3rd plot set: Parametric sin(): Deeper Observations @ 4kHz
#-------------------------------------------------------------------------------
yext_firstx = (min=90e-6, max=130e-6) #Common y-axis extents to compare times @ first crossing

plot1 = cons(:plot,
	ystrip1 = set(axislabel=LBL_AXIS_TIME, striplabel="Time to 1st falling crossing @4kHz (should decrease with increasing 𝜑ₒ)"; yext_firstx...),
	xaxis = set(label=xparam_reduce1),
)
push!(plot1,
	cons(:wfrm, fallx_at4k, lstylesweep, dfltglyph, label="@4k"),
)
plot2 = cons(:plot,
	ystrip1 = set(axislabel=LBL_AXIS_TIME, striplabel="Time to 1st falling crossing @4kHz (should be indep. of $xparam_reduce2)"; yext_firstx...),
	xaxis = set(label=xparam_reduce2),
)
push!(plot2,
	cons(:wfrm, fallx_at4kphi0, lstylesweep, dfltglyph, label="𝜑ₒ=0π"),
	cons(:wfrm, fallx_at4kphiπ_4, lstylesweep, dfltglyph, label="𝜑ₒ=π/4"),
)
pcoll = push!(cons(:plotcoll, title="Parametric sin() - Deeper Observations @ 4kHz"), plot1, plot2)
	pcoll.displaylegend=true
	pcoll.ncolumns = 1
display(pdisp, pcoll)
	savepng(pdisp, pcoll, "parametric_sin_3.png")
end
