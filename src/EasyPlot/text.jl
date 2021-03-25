#EasyPlot: Tools to manipulate text
#-------------------------------------------------------------------------------
#=TODO
 - Find a more practical font system than InspectDR.
=#


#==Useful constants
===============================================================================#


#==Main types
===============================================================================#
abstract type AbstractFont end

#=
mutable struct Font <: AbstractFont
	name::String
	_size::Float64
	bold::Bool
	color::Colorant
end
Font(name::String, _size::Real; bold::Bool=false, color=COLOR_BLACK) =
	Font(name, _size, bold, color)
Font(::PreDefaultsType) = Font(DEFAULT_FONTNAME, 10) #Construct some object
=#


