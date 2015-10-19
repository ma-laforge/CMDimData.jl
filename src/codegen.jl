#GracePlot code generation tools


#==Main data structures
===============================================================================#

#A type whose elements simply list valid attributes of a given object:
abstract AttributeList


#==Object builders
===============================================================================#

#Generate Expr for an "AttributeList" object constructor function.
#NOTE:
#   -Constructor function supports optional parameters.
#   -Assumes optional parameters can be "nothing".
#Inputs:
#   fnname: Object constructor name
#   t: data type to build
#   reqfieldcnt: # of required field/arguments (must be first object fields)
#TODO: Find way to restrict t::DataTypes <: AttributeList *without* wasting
#      space generating duplicate code
function genexpr_attriblistbuilder(fnname::Symbol, t::DataType; reqfieldcnt::Int=0)
	fieldlist = zip(t.names, t.types)

	#Build list of required parameters
	reqlist = Expr[]
	for i in 1:reqfieldcnt
		(name, _type) = (t.names[i], t.types[i])
		push!(reqlist, :($name::$_type))
	end

	#Build list of optional parameters
	optlist = Expr[]
	for i in reqfieldcnt+1:length(fieldlist)
		(name, _type) = (t.names[i], t.types[i])
		#Ignore argument types for now (assumes ::Any)...
		push!(optlist, Expr(:kw, name, nothing)) #Keyword assignment
	end

	#Build entire list of constructed object fields
	constlist = Symbol[]
	for (name, _type) in fieldlist
		push!(constlist, :($name))
	end

	constructorcall = Expr(:call, t, constlist...)
	return :($fnname($(reqlist...); $(optlist...)) = $constructorcall)
end

