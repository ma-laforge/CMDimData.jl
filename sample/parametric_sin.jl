#Parameter extraction of a parametric sinusoidal "simulation"
#-------------------------------------------------------------------------------
module CMDimData_SampleDemo

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
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


#==Helper functions
===============================================================================#
function savepng(pdisp, pcoll, filepath::String)
	#render() instead of display(), thus allowing settings to be tweaked
	rplot = render(pdisp, pcoll)
	wlegend = 250
	wp = rplot.layout[:halloc_plot] #Default plot width
	w = round(wp + wlegend); h = round(wp*1.5)
		for sp in rplot.subplots
			sp.layout[:halloc_legend] = wlegend
		end

	try
		EasyPlotInspect.InspectDR.write_png(filepath, rplot, w, h)
	catch
		@warn("Need InspectDR 0.3.10+ to write_png()")
	end
end


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


#==Generate plots
===============================================================================#

#plotset1: Parametric sin(): Initial observations
#-------------------------------------------------------------------------------
plot = cons(:plot, nstrips = 3,
	ystrip1 = set(axislabel=LBL_AXIS_POSITION, striplabel="Sinusoidal response"),
	ystrip2 = set(axislabel=LBL_AXIS_NORMPOSITION, striplabel="Normalized response (All peaks should be ±1)"),
	ystrip3 = set(axislabel=LBL_AXIS_SPEED, striplabel="Rate of change (should be larger for higher frequencies)"),
	xaxis = set(label=LBL_AXIS_TIME)
)
push!(plot,
	cons(:wfrm, signal, lstylesweep, label="", strip=1),
	cons(:wfrm, signal_norm, lstylesweep, label="", strip=2),
	cons(:wfrm, rate, lstylesweep, label="", strip=3),
)
plotset1 = push!(cons(:plotcoll, title="Parametric sin() - Initial Observations"), plot)
	plotset1.displaylegend=true
display(pdisp, plotset1)
	savepng(pdisp, plotset1, "parametric_sin_1.png")


#plotset2: Parametric sin(): Diving into parameter values
#-------------------------------------------------------------------------------
yext_firstx = (min=90e-6, max=130e-6) #Common y-axis extents to compare times @ first crossing

p1 = cons(:plot,
	ystrip1 = set(axislabel=LBL_AXIS_TIME, striplabel="Time to 1st fall-crossing (should decrease with $xred1)"), #; yext_firstx...),
	xaxis = set(label=xred1),
)
push!(p1, cons(:wfrm, fallx, lstylesweep, dfltglyph, label=""))

p2 = cons(:plot,
	ystrip1 = set(axislabel=LBL_AXIS_TIME, striplabel="Time to 1st fall-crossing @$xred1=$sdim1 (should be indep. of $xred2)"; yext_firstx...),
	xaxis = set(label=xred2),
)
push!(p2, cons(:wfrm, fallx_red1, lstylesweep, dfltglyph, label=""))

p3 = cons(:plot,
	ystrip1 = set(axislabel=LBL_AXIS_TIME, striplabel="Time to 1st fall-crossing @$xred2=$sdim2 (should decrease with increasing 𝜑ₒ)"; yext_firstx...),
	xaxis = set(label=xred3),
)
push!(p3, cons(:wfrm, fallx_red2, lstylesweep, dfltglyph, label=""))

plotset2 = push!(cons(:plotcoll, title="Parametric sin() - Diving into parameter values"), p1, p2, p3)
	plotset2.displaylegend=true
	plotset2.ncolumns = 1
display(pdisp, plotset2)
	savepng(pdisp, plotset2, "parametric_sin_2.png")

end #module
