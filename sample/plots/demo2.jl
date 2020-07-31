#Demo 2: Symbol test
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.EasyPlot
using CMDimData.MDDatasets


#==Attributes
===============================================================================#
infoaxes = cons(:attribute_list,
	xyaxes = set(xscale=:lin, yscale=:lin),
	labels = set(xaxis="X-Axis Label", yaxis="Y-Axis Label")
)
dfltwattr = cons(:attribute_list, #Default waveform attributes
	line = set(style=:solid, color=:red),
	glyph = set(shape=:square, size=3),
)


#==Input data
===============================================================================#
x = collect(0:1:10)
x = DataF1(x, 1*x)


#==Generate EasyPlot
===============================================================================#
plot = cons(:plot, infoaxes, title = "Symbol Test")
let xoffset=0, yoffset=0
for sz in [1, 3, 5]
	for w in [1, 2, 3]
		overw = cons(:a, line=set(color=:blue, width=w), glyph=set(size=sz))
		wfrm = push!(plot, cons(:wfrm, xshift(x+yoffset, xoffset), dfltwattr, overw, label="sz=$sz, w=$w"))
		xoffset += .5; yoffset += 10
	end
end
#Coarse width test
xoffset=0; #yoffset=0
for sz in [1, 2]
	for w in [1, 5, 10]
		overw = cons(:a, line=set(width=w), glyph=set(size=sz))
		wfrm = push!(plot, cons(:wfrm, xshift(x+yoffset, xoffset), dfltwattr, overw, label="sz=$sz, w=$w"))
		xoffset += .5; yoffset += 10
	end
end
end

pcoll = push!(cons(:plot_collection, title="Sample Plot"), plot)


#==Return pcoll to user (call evalfile(...))
===============================================================================#
pcoll
