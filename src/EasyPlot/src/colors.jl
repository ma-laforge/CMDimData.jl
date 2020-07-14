#EasyPlot color tools & color schemes
#-------------------------------------------------------------------------------


#==Additional constructors
===============================================================================#
rgbu8(r::UInt8, g::UInt8, b::UInt8) = 
	RGB24(r/255, g/255, b/255) #TODO: Write register directly?
rgbu8(r::Integer, g::Integer, b::Integer) = rgbu8(UInt8(r), UInt8(g), UInt8(b))


#==Types
===============================================================================#
struct FlagType{T}; end
const NOTFOUND = FlagType{:NOTFOUND}()

#TODO: merely typealias???
mutable struct ColorScheme
	colors::Vector{Colorant} #Colorant: might support alpha in the future
end


#==Useful internal constants
===============================================================================#
#Module users should access "external constants" instead.
const COLOR_TRANSPARENT = ARGB32(0, 0, 0, 0)

const COLOR_BLACK = RGB24(0, 0, 0)
const COLOR_WHITE = RGB24(1, 1, 1)
const COLOR_GREY85 = RGB24(.85, .85, .85)
const COLOR_GREY50 = RGB24(.5, .5, .5)

const COLOR_RED = RGB24(1, 0, 0)
const COLOR_GREEN = RGB24(0, 1, 0)
const COLOR_BLUE = RGB24(0, 0, 1)

const COLOR_YELLOW = RGB24(1, 1, 0)
const COLOR_YELLOW80 = RGB24(.8, .8, 0)
const COLOR_CYAN = RGB24(0, 1, 1)
const COLOR_MAGENTA = RGB24(1, 0, 1)

const COLOR_BROWN = rgbu8(188, 143, 143)
const COLOR_ORANGE = rgbu8(255, 165, 0)
const COLOR_INDIGO = rgbu8(114, 33, 188)
const COLOR_VIOLET = rgbu8(148, 0, 211)
const COLOR_MAROON = rgbu8(103, 7, 72)
const COLOR_TURQUOISE = rgbu8(64, 224, 208)

const COLORSCHEME_DEFAULT = ColorScheme(
	[COLOR_BLUE, COLOR_YELLOW80, COLOR_RED, COLOR_CYAN, COLOR_GREEN,
	COLOR_MAGENTA, COLOR_ORANGE, COLOR_VIOLET, COLOR_GREY50]
)


#==Useful external constants
===============================================================================#
#Module users should access these functions

const COLOR_NAMED = Dict{Symbol, Colorant}(
	:none => COLOR_TRANSPARENT,
	:transparent => COLOR_TRANSPARENT,

	:black => COLOR_BLACK,
	:white => COLOR_WHITE,
	:grey85 => COLOR_GREY85,

	:red => COLOR_RED,
	:green => COLOR_GREEN,
	:blue => COLOR_BLUE,

	:yellow => COLOR_YELLOW,
	:cyan => COLOR_CYAN,
	:magenta => COLOR_MAGENTA,

	:brown => COLOR_BROWN,
	:orange => COLOR_ORANGE,
	:indigo => COLOR_INDIGO,
	:violet => COLOR_VIOLET,
	:maroon => COLOR_MAROON,
	:turquoise => COLOR_TURQUOISE,
)

const COLORSCHEME = Dict{Symbol, ColorScheme}(
	:default => COLORSCHEME_DEFAULT,
)


#==Selecting colors
===============================================================================#
getcolor(s::ColorScheme, ::Nothing) = COLOR_BLACK #TODO: something better?

#Assumes value "v" starts at 1 (not 0):
function getcolor(s::ColorScheme, v::Integer)
	idx = mod(v-1, length(s.colors)) + 1
	return s.colors[idx]
end

#Default behaviour: ignore color scheme, and get color
#Alternative: Find closest color in scheme?
function getcolor(s::ColorScheme, v::Symbol)
	if :default == v
		return getcolor(s, nothing)
	end

	result = get(COLOR_NAMED, v, NOTFOUND)
	if NOTFOUND == result
		@info("Color not supported: $v")
		result = getcolor(s, nothing)
	end
	return result
end

#Default behaviour: ignore color scheme, and get color
#Alternative: Find closest color in scheme?
getcolor(s::ColorScheme, v::Colorant) = v

#Last line
