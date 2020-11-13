using CMDimData.EasyPlot
using CMDimData.MDDatasets
using Colors

@testset "EasyPlot tests" begin #Scope for test data


#==Basic Tests
===============================================================================#
@testset "Creating basic Plot object" begin
	show_testset_description()
	#WARN: d1==d2 creates new DataF1 with 0s when y-values mismatch.
	issame(d1::DataF1, d2::DataF1) = (d1===d2)

	#Data
	x = collect(1:10)
	d1 = DataF1(x, x.^2)

	dfltline = cons(:a, line=set(style=:dash, color=:red))
	dfltglyph = cons(:a, glyph=set(shape=:square, size=3))
	axes_loglin = cons(:a, xyaxes=set(xscale=:log, yscale=:lin))

	splot1attr = cons(:attribute_list,
		xyaxes = set(xscale=:lin, yscale=:log),
		labels = set(xaxis="Frequency (Hz)", yaxis="Peak Current (A)"),
	)
	bodeplotattr = append!(cons(:attribute_list,
		nstrips=2, xaxis=set(scale=:log10),
		labels = set(title="Bode Plot", xaxis="Frequency (Hz)"),
		ystrip = set(1, scale=:dB20, axislabel="Magnitude (dB)"),
	), cons(:attribute_list,
		ystrip = set(2, scale=:lin, axislabel="Phase (°)"),
	))

	w = cons(:wfrm, d1, label="v1", dfltline, dfltglyph)
		@test issame(w.data, d1)
		@test w.label == "v1"
		@test w.line.style == :dash
		@test w.line.color == colorant"red"
		@test w.glyph.shape == :square
		@test w.glyph.size == 3

	set(w, cons(:a, line=set(width=22)))
		@test w.line.width == 22

	plt1 = push!(cons(:plot, title="PTitle", splot1attr),
		cons(:wfrm, d1, label="v1", dfltglyph, dfltline),
		cons(:wfrm, d1, label="v2", line=set(style=:dot, width=.001)),
	)
		@test plt1.title == "PTitle"
		@test length(plt1.ystriplist) == 1
		@test plt1.xaxis == EasyPlot.Axis(:lin)
		@test plt1.ystriplist[1].scale == :log
	w = plt1.wfrmlist[1]
		@test w.label == "v1"
		@test w.line.style == :dash
		@test w.line.color == colorant"red"
		@test w.glyph.shape == :square
		@test w.glyph.size == 3
	w = plt1.wfrmlist[2]
		@test w.label == "v2"
		@test w.line.style == :dot
		@test w.line.width == .001
	set(plt1, axes_loglin)
		@test plt1.xaxis == EasyPlot.Axis(:log)
		@test plt1.ystriplist[1].scale == :lin

	plt2 = push!(cons(:plot, bodeplotattr),
		cons(:wfrm, d1, label="meas", strip=2),
		cons(:wfrm, d1, label="meas", strip=1),
	)
		@test plt2.title == "Bode Plot"
		@test length(plt2.ystriplist) == 2
		@test plt2.xlabel == "Frequency (Hz)"
		@test plt2.xaxis == EasyPlot.Axis(:log10)
		@test plt2.ystriplist[1].scale == :dB20
		@test plt2.ystriplist[1].axislabel == "Magnitude (dB)"
		@test plt2.ystriplist[2].scale == :lin
		@test plt2.ystriplist[2].axislabel == "Phase (°)"
	w = plt2.wfrmlist[1]
		@test w.label == "meas"
		@test w.strip == 2
	w = plt2.wfrmlist[2]
		@test w.strip == 1

	pcoll = push!(cons(:plot_collection, title="MyPlot"), plt1, plt2)
		@test pcoll.title == "MyPlot"
		@test length(pcoll.plotlist) == 2
		@test pcoll.plotlist[1] == plt1
		@test pcoll.plotlist[2] == plt2
end

@testset "Creating demo Plot object" begin
	show_testset_description()
	filelist = EasyPlot.demofilelist()

	for f in filelist
		printsep("Evaluating plots in $f...")
		#throw(:SAMPLERROR)
		@show pcoll=evalfile(f);
	end
end
end

#Last line
