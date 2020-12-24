#bld_parametric_sin_explore.jl: Parametric sin(): Diving into parameter values
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
	yext_firstx = (min=90e-6, max=130e-6) #Common y-axis extents to compare times @ first crossing
	#shorthand:
	xred1 = data.xred1; xred2 = data.xred2; xred3 = data.xred3
	sdim1 = data.sdim1; sdim2 = data.sdim2

	p1 = cons(:plot,
		ystrip1 = set(axislabel=LBL_AXIS_TIME, striplabel="Time to 1st fall-crossing (should decrease with $xred1)"), #; yext_firstx...),
		xaxis = set(label=xred1),
	)
	push!(p1, cons(:wfrm, data.fallx, lstylesweep, dfltglyph, label=""))

	p2 = cons(:plot,
		ystrip1 = set(axislabel=LBL_AXIS_TIME, striplabel="Time to 1st fall-crossing @$xred1=$sdim1 (should be indep. of $xred2)"; yext_firstx...),
		xaxis = set(label=xred2),
	)
	push!(p2, cons(:wfrm, data.fallx_red1, lstylesweep, dfltglyph, label=""))

	p3 = cons(:plot,
		ystrip1 = set(axislabel=LBL_AXIS_TIME, striplabel="Time to 1st fall-crossing @$xred2=$sdim2 (should decrease with increasing 𝜑ₒ)"; yext_firstx...),
		xaxis = set(label=xred3),
	)
	push!(p3, cons(:wfrm, data.fallx_red2, lstylesweep, dfltglyph, label=""))

	pcoll = cons(:plotcoll, title="Parametric sin() - Diving into parameter values", ncolumns=1)
		push!(pcoll, p1, p2, p3)
	return pcoll
end

#Return EasyPlotBuilder object:
EasyPlot.EasyPlotBuilder(fnbuild)
