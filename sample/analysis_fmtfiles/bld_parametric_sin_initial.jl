#bld_parametric_sin_initial.jl: Parametric sin(): Initial observations
#-------------------------------------------------------------------------------
using CMDimData
using CMDimData.EasyPlot


#==Constants
===============================================================================#
LBL_AXIS_TIME = "Time [s]"
LBL_AXIS_POSITION = "Position [m]"
LBL_AXIS_NORMPOSITION = "Normalized Pos [m/m]"
LBL_AXIS_SPEED = "Speed [m/s]"
lstylesweep = cons(:a, line = set(style=:solid, width=2)) #Default is a bit thin
dfltglyph = cons(:a, glyph = set(shape=:o, size=1.5))

function fnbuild(data)
	plot = cons(:plot, nstrips = 3,
		ystrip1 = set(axislabel=LBL_AXIS_POSITION, striplabel="Sinusoidal response"),
		ystrip2 = set(axislabel=LBL_AXIS_NORMPOSITION, striplabel="Normalized response (All peaks should be ±1)"),
		ystrip3 = set(axislabel=LBL_AXIS_SPEED, striplabel="Rate of change (should be larger for higher frequencies)"),
		xaxis = set(label=LBL_AXIS_TIME)
	)
	push!(plot,
		cons(:wfrm, data.signal, lstylesweep, label="", strip=1),
		cons(:wfrm, data.signal_norm, lstylesweep, label="", strip=2),
		cons(:wfrm, data.rate, lstylesweep, label="", strip=3),
	)
	pcoll = push!(cons(:plotcoll, title="Parametric sin() - Initial Observations"), plot)
	return pcoll
end

#Return EasyPlotBuilder object:
EasyPlot.EasyPlotBuilder(fnbuild)
