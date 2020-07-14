@testset "EasyPlot tests" begin #Scope for test data


#==Basic Tests
===============================================================================#
@testset "Creating basic Plot object" begin
	show_testset_description()

	dfltline = line(style=:solid, color=:red)
	dfltglyph = glyph(shape=:square, size=3)
	axes_loglin = paxes(xscale = :log, yscale = :lin)

	#Data
	x = collect(1:10)
	d1 = DataF1(x, x.^2)
global subplot
	plot = EasyPlot.new(title = "Sample Plot")
		@test plot.title == "Sample Plot"
	subplot = add(plot, axes_loglin, title = "Subplot 1")
		@test subplot.title == "Subplot 1"
		@test subplot.axes.xscale == :log
		@test subplot.axes.yscale == :lin

	wfrm = add(subplot, d1, id="Quadratic")
		@test wfrm.line.color == nothing
		@test wfrm.line.style == nothing
		@test wfrm.line.width == nothing
	set(wfrm, dfltline, dfltglyph)
		@test wfrm.id == "Quadratic"
		@test wfrm.line.color == :red
		@test wfrm.line.style == :solid
		@test wfrm.glyph.shape == :square
		@test wfrm.glyph.size == 3

	@test length(subplot.wfrmlist) == 1
end

@testset "Creating demo Plot object" begin
	show_testset_description()
	filelist = EasyPlot.demofilelist()

	for f in filelist
		printsep("Evaluating plot in $f...")
		#throw(:SAMPLERROR)
		@show p=evalfile(f);
	end
end

end
