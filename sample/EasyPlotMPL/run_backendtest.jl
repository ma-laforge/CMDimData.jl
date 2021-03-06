#Test different backends of EasyPlotMPL/PyPlot
#-------------------------------------------------------------------------------
module CMDimData_SampleUsage

using CMDimData
using CMDimData.EasyPlot
CMDimData.@includepkg EasyPlotMPL


#==Constants
===============================================================================#
backendtestlist = [:tk, :gtk3, :gtk, :qt, :wx]
demolist = EasyPlot.demofilelist()


#==Helper functions
===============================================================================#
printsep(label, sep="-") = println("\n", label, "\n", repeat(sep, 80))
printheader(label) = printsep(label, "=")


#==Display sample EasyPlot plots on different PyPlot backends
===============================================================================#
printheader("PyPlot backend test")
plot = evalfile(demolist[1])
for backend in backendtestlist
	printsep("Backend $backend...")
	plot.title = "Backend: $backend"
	try
		disp = EasyPlot.GUIDisplay(:PyPlot, backend=backend)
		display(disp, plot)
	catch e
		@warn e.msg
	end
end

end #module
:SampleCode_Executed
