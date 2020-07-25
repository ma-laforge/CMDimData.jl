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
avst = paxes(xlabel="Time (s)", ylabel="Amplitude (m)")
rvst = paxes(xlabel="Time (s)", ylabel="Rate (m/s)")
pvst = paxes(xlabel="Time (s)", ylabel="Position (m)")
lstylesweep = line(style=:solid, width=2) #Default is a bit thin
lstyle1 = line(color=:red, width=2, style=:solid)
lstyle2 = line(color=:blue, width=2)
dfltglyph = glyph(shape=:o, size=1.5)


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
function savepng(pdisp, plot, filepath::String)
	#render() instead of display(), thus allowing settings to be tweaked
	rplot = render(pdisp, plot) #rendered plot
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
plot=EasyPlot.new(title="Parametric sin() - Results #1")
	plot.displaylegend=true
s = add(plot, pvst, title="Sinusoidal response") #Subplot
	add(s, signal, lstylesweep, id="signal")
s = add(plot, pvst, title="Normalized response") #Subplot
	add(s, signal_norm, lstylesweep, id="signal_norm")
s = add(plot, rvst, title="Rate of change") #Subplot
	add(s, rate, lstylesweep, id="rate")
plot.ncolumns = 1
display(pdisp, plot)
	savepng(pdisp, plot, "parametric_sin_1.png")

plot=EasyPlot.new(title="Parametric sin() - Results #2")
	plot.displaylegend=true
s = add(plot, title="Maximum Rate of Signal") #Subplot
	set(s, paxes(xlabel=xparam, ylabel="Rate (m/s)"))
	add(s, maxrate, lstylesweep, dfltglyph, id="maxrate")
s = add(plot, title="Time to first falling crossing") #Subplot
	set(s, paxes(xlabel=xparam, ylabel="Time (s)"))
	add(s, fallx, lstylesweep, dfltglyph, id="fallx")
plot.ncolumns = 1
display(pdisp, plot)
	savepng(pdisp, plot, "parametric_sin_2.png")

plot=EasyPlot.new(title="Parametric sin() - Results #3")
	plot.displaylegend=true
s = add(plot, title="Time to first falling crossing (f=4kHz)") #Subplot
	set(s, paxes(xlabel=xparam_reduce1, ylabel="Time (s)"))
	add(s, fallx_at4k, lstylesweep, dfltglyph, id="fallx@4k")
s = add(plot, title="Time to first falling crossing (f=4kHz, phi=0)") #Subplot
	set(s, paxes(xlabel=xparam_reduce2, ylabel="Time (s)"))
	add(s, fallx_at4kphi0, lstylesweep, dfltglyph, id="fallx@4kphi0")
	set(s, paxes(ymin=0, ymax=150e-6)) #Circumvent bug with InspectDR when ymin==ymax
plot.ncolumns = 1
display(pdisp, plot)
	savepng(pdisp, plot, "parametric_sin_3.png")

	return
end
