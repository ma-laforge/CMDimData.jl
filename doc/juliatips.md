# CMDimData: Julia tips

 1. [`linspace()` & `logspace()`](#LinLogSpace)

<a name="LinLogSpace"></a>
## `linspace()` & `logspace()`
`linspace()` & `logspace()` don't exist in Julia 1.0+. Instead, you should use `range()`:

 1. `range(start, stop=stop, length=n)`: Constructs a `StepRangeLen` object.
     - `collect(range(0, stop=100, length=101))`: Generates a `Vector{Float64}` (not `Vector{Int}`).
 1. `10 .^ range(start, stop=stop, length=n)`: Generates a `Vector{Float64}` object.
     - `10 .^ range(-10, stop=10, length=101)`: Log-spaced values &isin; [1.0e-10, 1.0e10].

