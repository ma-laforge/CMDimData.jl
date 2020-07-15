#demo2: Symbol test
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.EasyPlot
using CMDimData.MDDatasets

#==Constants
===============================================================================#
const linlin = paxes(xscale = :lin, yscale = :lin)
const alabels = paxes(xlabel="X-Axis Label", ylabel="X-Axis Label")

#Defaults
#-------------------------------------------------------------------------------
dfltline = line(style=:solid, color=:red)
dfltglyph = glyph(shape=:square, size=3)


#==Input data
===============================================================================#
x = collect(0:1:10)
x = DataF1(x, 1*x)


#==Generate EasyPlot
===============================================================================#
plot = EasyPlot.new(title = "Sample Plot")
subplot = add(plot, linlin, alabels, title = "Symbol Test")
let xoffset=0, yoffset=0
for sz in [1, 3, 5]
	for w in [1, 2, 3]
		wfrm = add(subplot, xshift(x+yoffset, xoffset), id="sz=$sz, w=$w")
		set(wfrm, line(style=:solid, color=:red, width=w), glyph(shape=:square, size=sz))
		xoffset += .5; yoffset += 10
	end
end
#Coarse width test
xoffset=0; #yoffset=0
for sz in [1, 2]
	for w in [1, 5, 10]
		wfrm = add(subplot, xshift(x+yoffset, xoffset), id="sz=$sz, w=$w")
		set(wfrm, line(style=:solid, color=:blue, width=w), glyph(shape=:square, size=sz))
		xoffset += .5; yoffset += 10
	end
end
end


#==Return plot to user (call evalfile(...))
===============================================================================#
plot

#Last line
