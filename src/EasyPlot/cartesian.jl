#EasyPlot: Cartesian coordinates, operations, and other tools.
#-------------------------------------------------------------------------------


#==Useful constants
===============================================================================#
#Real values for plot coordinates, etc:
const PReal = Float64
const PInf = convert(PReal, Inf)
const PNaN = convert(PReal, NaN)


#==Main types
===============================================================================#
#TODO: Use library version?
abstract type Point end #So we can use as a function
struct Point2D <: Point
	x::PReal
	y::PReal
end

abstract type DirectionalVector end
struct Vector2D <: DirectionalVector
	x::PReal
	y::PReal
end
Vector2D(p::Point2D) = Vector2D(p.x, p.y)
Point2D(p::Vector2D) = Point2D(p.x, p.y)

struct Extents1D
	min::PReal
	max::PReal
end
_Extents1D() = Extents1D(PNaN, PNaN)

#Offsettable 2D position:
mutable struct Pos2DOffset
	v::Point2D #Position (Plot coordinates) - set NaN to use offsets only
	reloffset::Vector2D #Relative offset (Normalized to [0,1] graph bounds; depends on zoom level)
	offset::Vector2D #Absolute offset (device units)
end

#Last line
