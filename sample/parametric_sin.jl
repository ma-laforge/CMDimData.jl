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
vvst = cons(:a, labels = set(xaxis="Time (s)", yaxis="Amplitude (m)"))
rvst = cons(:a, labels = set(xaxis="Time (s)", yaxis="Rate (m/s)"))
pvst = cons(:a, labels = set(xaxis="Time (s)", yaxis="Position (m)"))
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
@show ndims(fallx_at4kphi0)
@show xparam_reduce2 = paramlist(fallx_at4kphi0)[end]


#==Generate plots
===============================================================================#
plot1 = push!(cons(:plot, pvst, title="Sinusoidal response"),
	cons(:wfrm, signal, lstylesweep, label="signal"),
)
plot2 = push!(cons(:plot, pvst, title="Normalized response"),
	cons(:wfrm, signal_norm, lstylesweep, label="signal_norm"),
)
plot3 = push!(cons(:plot, rvst, title="Rate of change"),
	cons(:wfrm, rate, lstylesweep, label="rate"),
)
pcoll = push!(cons(:plotcoll, title="Parametric sin() - Results #1"), plot1, plot2, plot3)
	pcoll.displaylegend=true
	pcoll.ncolumns = 1
display(pdisp, pcoll)
	savepng(pdisp, pcoll, "parametric_sin_1.png")


plot1 = cons(:plot, title="Maximum Rate of Signal",
	labels = set(xaxis=xparam, yaxis="Rate (m/s)"),
)
push!(plot1,
	cons(:wfrm, maxrate, lstylesweep, dfltglyph, label="maxrate"),
)
plot2 = cons(:plot, title="Time to first falling crossing",
	labels = set(xaxis=xparam, yaxis="Time (s)"),
)
push!(plot2,
	cons(:wfrm, fallx, lstylesweep, dfltglyph, label="fallx"),
)
pcoll = push!(cons(:plotcoll, title="Parametric sin() - Results #2"), plot1, plot2)
	pcoll.displaylegend=true
	pcoll.ncolumns = 1
display(pdisp, pcoll)
	savepng(pdisp, pcoll, "parametric_sin_2.png")


plot1 = cons(:plot, title="Time to first falling crossing (f=4kHz)",
	labels = set(xaxis=xparam_reduce1, yaxis="Time (s)"),
)
push!(plot1,
	cons(:wfrm, fallx_at4k, lstylesweep, dfltglyph, label="fallx@4k"),
)
plot2 = cons(:plot, title="Time to first falling crossing (f=4kHz, phi=0)",
	xyaxes = set(ymin=0, ymax=150e-6), #Circumvent bug with InspectDR when ymin==ymax
	labels = set(xaxis=xparam_reduce2, yaxis="Time (s)"),
)
push!(plot2,
	cons(:wfrm, fallx_at4kphi0, lstylesweep, dfltglyph, label="fallx@4kphi0"),
)
pcoll = push!(cons(:plotcoll, title="Parametric sin() - Results #3"), plot1, plot2)
	pcoll.displaylegend=true
	pcoll.ncolumns = 1
display(pdisp, pcoll)
	savepng(pdisp, pcoll, "parametric_sin_3.png")
end
