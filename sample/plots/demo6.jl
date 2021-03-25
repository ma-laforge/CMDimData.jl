#Demo 6: Bode Plot
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.EasyPlot
using CMDimData.MDDatasets
using Colors
import Printf: @sprintf


#==Attributes
===============================================================================#
dfltline = cons(:a, line=set(style=:solid, color=:blue, width=3))
markerline = cons(:a, line=set(style=:dash, width=2.5))
markerline_light = cons(:a, line=set(style=:dash, width=2.5, color=RGB24(.4,.4,.4)))
dfltglyph = cons(:a, glyph=set(shape=:square, size=3))


#==Input data
===============================================================================#
j = im
G = 20.0; 𝑓_p1 = 50e6; 𝑓_p2 = .9e9; 𝑓_z = Inf #.8e9
𝑓step = 5e6; 𝑓max = 10e9
𝑓min_disp = 10e6


#==Helper functions
===============================================================================#
phase(x) = rad2deg(angle(x))
function roots(a,b,c)
	r = sqrt(b*b-4*a*c)
	result = (-b .+ [r, -r]) / (2a)
	return (result[1], result[2])
end
xf_o2(f, G, f_z, f_p1, f_p2) = #2nd order transfer function
	G*(1 + j*(f/f_z)) / ( (1 + j*(f/f_p1)) * (1 + j*(f/f_p2)) )
function f_unitygain(f, G, f_z, f_p1, f_p2) #Compute unity gain frequency
	invsq(x) = (result = 1/x; return result*result)
	_z² = invsq(f_z); G² = G*G
	_p1² = invsq(f_p1); _p2² = invsq(f_p2)
	r = roots(_p1²*_p2², _p1²+_p2²-G²*_z², 1-G²) 
	return sqrt(max(r...)) #Select sqrt(positive root)
end
f_3dB(f, G, f_z, f_p1, f_p2) = #Compute 3dB frequency
	f_unitygain(f, sqrt(2), f_z, f_p1, f_p2)


#==Calculations
===============================================================================#
𝑓 = DataF1(0:𝑓step:𝑓max)
X = xf_o2(𝑓, G, 𝑓_z, 𝑓_p1, 𝑓_p2)
𝑓0 = f_unitygain(𝑓, G, 𝑓_z, 𝑓_p1, 𝑓_p2)
𝑓BW = f_3dB(𝑓, G, 𝑓_z, 𝑓_p1, 𝑓_p2)
phase0 = phase(xf_o2(𝑓0, G, 𝑓_z, 𝑓_p1, 𝑓_p2))
pmargin = 180+phase0
@show pmargin


#==Generate EasyPlot
===============================================================================#
gridconf = set(vmajor = true, vminor = true, hmajor=false, hminor=false)
plot = cons(:plot, nstrips=2, legend=false, title = "Sample Bode Plot",
	xaxis = set(scale=:log, label="Frequency [Hz]", min=𝑓min_disp), #Avoid issues with log scale
	ystrip1 = set(scale=:dB20, axislabel="Magnitude [dB]", min=-10),
	ystrip2 = set(scale=:lin, axislabel="Phase [°]", min=-180),
	grid1 = gridconf, grid2 = gridconf
)

push!(plot,
	cons(:wfrm, abs(X), dfltline, label="|X|", strip=1),
	cons(:wfrm, phase(X), dfltline, label="∠X", strip=2),
)

𝑓3dBstr = @sprintf("𝑓3dB=%.1f MHz", 𝑓BW/1e6)
𝑓0str = @sprintf("𝑓0=%.1f MHz", 𝑓0/1e6)
pmstr = @sprintf("PM=%.1f°", pmargin)

push!(plot,
	cons(:atext, 𝑓3dBstr, x=𝑓BW, offset=set(x=-3), reloffset=set(y=.5), angle=-90, align=:bc, strip=1),
	cons(:atext, 𝑓0str, x=𝑓0, offset=set(x=-3), reloffset=set(y=.5), angle=-90, align=:bc, strip=1),
	cons(:atext, "0dB", y=0, reloffset=set(x=0.5), offset=set(y=3), align=:bc, strip=1),
	cons(:atext, pmstr, y=(phase0-180)/2, reloffset=set(x=0.5), align=:cc, strip=2),
)

#Add H/V markers to plot:
push!(plot,
	cons(:vmarker, 𝑓0, markerline, strip=0),
	cons(:vmarker, 𝑓BW, markerline, strip=0),
	cons(:hmarker, 0, markerline_light, strip=1),
	cons(:hmarker, phase0, markerline, strip=2),
)


pcoll = push!(cons(:plotcoll, title="Bode Test"), plot)

CMDimData.@includepkg EasyPlotInspect
plotgui = EasyPlot.displaygui(:InspectDR, pcoll)
ploth = 500; plotw = round(Int, ploth*1.6)
EasyPlot._write(:png, "demo6_test.png", plotgui, dim=set(w=plotw, h=ploth))


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll

