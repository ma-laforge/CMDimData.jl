#Parameter extraction of a parametric sinusoidal "simulation"
#-------------------------------------------------------------------------------
module CMDimData_SampleUsage

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotInspect


#==Constants
===============================================================================#
WIDTH_LEGEND = 250
WIDTH_DATA = 600 #Approx
WIDTH_PLOT = WIDTH_DATA+WIDTH_LEGEND
HEIGHT_PLOT = round(Int, WIDTH_DATA/3) #Total is roughly square
HEIGHT_CANVAS = round(Int, 3*HEIGHT_PLOT*1.2) #Add extra for overhead (titles, etc)


#==Read in results of parametric "simulation"
===============================================================================#
signal = evalfile("parametric_sin_data.jl")


#==Parameter extraction
===============================================================================#
sdim1 = 4e3 #Sample dimension 1 @ 𝑓=4kHz
sdim2 = .002 #Sample dimension 2 @ A=.002

println()
@info("Information on `signal`:")
@show ndims(signal), paramlist(signal)

#Convenience: x-value resulting from paramter reduction operations:
x_paramreduce = reverse(paramlist(signal))

#Generate DataRS with value of amplitude (A) in each parameter combination:
ampvalue = parameter(signal, "A")

#Normalize signal amplitudes for ALL signals SIMULTANEOUSLY:
signal_norm = signal / ampvalue

#Compute continuous-time signal rate for ALL signals SIMULTANEOUSLY:
#   signal(𝜙, A, 𝑓, t) -> rate(𝜙, A, 𝑓):
rate = deriv(signal)

println()
@info("Reduction 0: Compute `fallx`: First fall-crossing point for ALL signals SIMULTANEOUSLY:")
#   signal(𝜙, A, 𝑓, t) -> fallx(𝜙, A, 𝑓):
fallx = xcross1(signal, xstart=0, allow=CrossType(:fall))
@show ndims(fallx), paramlist(fallx)
@show xred1 = x_paramreduce[1] #x-value for 1st fallx reduction

println()
@info("Reduction 1: Evaluate `fallx` @ $xred1=$sdim1 (=>`fallx_red1`):")
#   fallx(𝜙, A, 𝑓) -> fallx_red1(𝜙, A):
fallx_red1 = value(fallx, x=sdim1)
@show ndims(fallx_red1), paramlist(fallx_red1)
@show xred2 = x_paramreduce[2] #x-value for 2nd fallx reduction

println()
@info("Reduction 2: Evaluate `fallx_red1` @ $xred2=$sdim2 (=>`fallx_red2`):")
#   fallx_red1(𝜙, A) -> fallx_red2(𝜙):
fallx_red2 = value(fallx_red1, x=sdim2)
@show ndims(fallx_red2), paramlist(fallx_red2)
@show xred3 = x_paramreduce[3] #x-value for 3rd fallx reduction

data = (
	signal = signal, signal_norm = signal_norm,
	rate = rate, fallx = fallx,
	fallx_red1 = fallx_red1, fallx_red2 = fallx_red2,
	xred1 = xred1, xred2 = xred2,	xred3 = xred3,
	sdim1 = sdim1,	sdim2 = sdim2,
)

#==Generate plots
===============================================================================#
PB = EasyPlot.load_plotbuilders(@__DIR__,
	initial = "bld_parametric_sin_initial.jl",
	explore = "bld_parametric_sin_explore.jl",
)

function adjust_legend(gtkplot)
	mplot = gtkplot.src
	for sp in mplot.subplots
		sp.layout[:halloc_legend] = WIDTH_LEGEND
	end
end
plotdisplay = EasyPlot.GUIDisplay(:InspectDR, postproc=adjust_legend)
	opt = EasyPlot.ShowOptions(dim=set(w=WIDTH_PLOT, h=HEIGHT_CANVAS))

plotset1 = EasyPlot.build(PB[:initial], data)
	plotgui1 = display(plotdisplay, plotset1)
	EasyPlot._write(:png, "parametric_sin_initial.png", opt, plotgui1)
plotset2 = EasyPlot.build(PB[:explore], data)
	plotgui2 = display(plotdisplay, plotset2)
	EasyPlot._write(:png, "parametric_sin_explore.png", opt, plotgui2)

end #module
:SampleCode_Executed
