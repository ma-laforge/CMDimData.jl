#"Read" data for parametric sinusoidal "simulation" & parameter extraction
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.MDDatasets

const π = MathConstants.π

#==Emulate reading in simulated data file
===============================================================================#

#=COMMENT
The code below emulates a parametric "simulation" of a sinusoidal response where
the 𝜙, A, and 𝑓 parameters of `signal = A * sin(𝜔*t + 𝜙); 𝜔 = 2π*𝑓` are varied.

The parametric signal can therefore be fully represented as:
	signal(𝜙, A, 𝑓, t)
=#

#But really construct multidimensional DataRS dataset manually:
signal = fill(DataRS, PSweep("phi", [0, 0.5, 1] .* (π/4))) do 𝜙
	fill(DataRS, PSweep("A", [1, 2, 4] .* 1e-3)) do A
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

return signal
