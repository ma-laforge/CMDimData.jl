#EasyPlot core type, constant & function definitions
#-------------------------------------------------------------------------------


#==Types & constants
===============================================================================#
#Real values for plot coordinates, etc:
const PReal = Float64
const PNaN = PReal(NaN)

#Dispatchable symbol (minimize namespace pollution):
struct DS{T}; end
DS(v::Symbol) = DS{v}()

"`Optional{T} = Union{Nothing, T}`"
const Optional{T} = Union{Nothing, T}

struct Default; end
const default = Default()

struct NoOverwrite; end #Alt?: NoChange, KeepValue
const nooverwrite = NoOverwrite()


#==Accessors
===============================================================================#
"""`NoOverwrite(v)`

Test whether a value is of type "NoOverwrite"."""
NoOverwrite(v) = false
NoOverwrite(v::NoOverwrite) = true


#==Helper functions
===============================================================================#
SI(v; ndigits=3) = NumericIO.formatted(v, :SI, ndigits=ndigits)


#==Documentation
===============================================================================#
@doc """`Default`

Empty type whose singleton instance `default` represents a default value.
""" Default

@doc """`default`

Singleton instance of type `Default` representing a default value.
""" default

@doc """`NoOverwrite`

Empty type whose singleton instance `nooverwrite` indicates an attribute should
not be overwritten.
""" NoOverwrite

@doc """`nooverwrite`

Singleton instance of type `NoOverwrite`.
Identifies an attribute that should not be overwritten.
""" nooverwrite

#Last line
