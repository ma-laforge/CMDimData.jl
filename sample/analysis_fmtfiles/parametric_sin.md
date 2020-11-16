# [parametric\_sin.jl](parametric_sin.jl): Characterization/extractions from results of parametric sinusoidal "simulation"

The following gives a coarse, high-level walkthrough of the [parametric\_sin.jl](parametric_sin.jl) example.

## Include base multidimensional capabilities
```julia
using MDDatasets
```

## Generate data
The code below emulates a parametric "simulation" of a sinusoidal response where
the `𝜙`, `A`, and `𝑓` parameters of `signal = A * sin(𝜔*t + 𝜙); 𝜔 = 2π*𝑓` are varied.

The parametric signal can therefore be fully represented as:
```
signal(𝜙, A, 𝑓, t)
```

*(But really construct multidimensional `DataRS` dataset from ideal equations):*
```julia
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
```

<img src="https://github.com/ma-laforge/FileRepo/blob/master/CMDimData/parametric_sin/signal.png">

## Example: Compute normalized version of multidimensional `signal`

Generate new signal with proper value of (`A`) for each parametric combination:
```julia
julia> ampvalue = parameter(signal, "A")

ampvalue = DataRS[
  phi=0.0: 
    A=0.001: 
      freq=1000.0: 0.001
      freq=4000.0: 0.001
      freq=16000.0: 0.001
    A=0.002: 
      freq=1000.0: 0.002
      freq=4000.0: 0.002
      freq=16000.0: 0.002
[...]
]
```

Normalize signal amplitudes for *all* parametric combinations of `signal` *simultaneously*:
```julia
signal_norm = signal / ampvalue
```

<img src="https://github.com/ma-laforge/FileRepo/blob/master/CMDimData/parametric_sin/signal_norm.png">

## Example: Compute continuous-time signal `rate`
Which is automatically performed for *all* parametric combinations of `signal` *simultaneously*:
```julia
rate = deriv(signal)
```

<img src="https://github.com/ma-laforge/FileRepo/blob/master/CMDimData/parametric_sin/rate.png">

## Reduction example: Locate first fall-crossing point of `signal`: `fallx`
Which is automatically performed for *all* parametric combinations of `signal` *simultaneously*:
```julia
fallx = xcross1(signal, xstart=0, allow=CrossType(:fall))
```

Note that `xcross1()` results in a dimensional reduction of `signal(𝜙, A, 𝑓, t)` &rArr; `fallx(𝜙, A, 𝑓)`.

<img src="https://github.com/ma-laforge/FileRepo/blob/master/CMDimData/parametric_sin/fallx.png">

## Reduction example: Evaluate `fallx` @ `𝑓=4kHz`
Which is automatically performed for *all* parametric combinations of `signal` *simultaneously*:
```julia
fallx_red1 = value(fallx, x=4e3)
```

Here, `value()` results in a dimensional reduction of `fallx(𝜙, A, 𝑓)` &rArr; `fallx_red1(𝜙, A)`.

<img src="https://github.com/ma-laforge/FileRepo/blob/master/CMDimData/parametric_sin/fallx_red1.png">

## Reduction example: Evaluate `fallx_red1` @ `A=0.002`
Which is automatically performed for *all* parametric combinations of `signal` *simultaneously*:
```julia
fallx_red2 = value(fallx, x=.002)
```

Here, `value()` results in a dimensional reduction of `fallx_red1(𝜙, A)` &rArr; `fallx_red2(𝜙)`.

<img src="https://github.com/ma-laforge/FileRepo/blob/master/CMDimData/parametric_sin/fallx_red2.png">

## Plotting example
Straightforward plotting of multidimensional datasets is provided by the `CMDimData/EasyPlot` module:
```julia
using CMDimData
using CMDimData.EasyPlot
```

Note that `EasyPlot` only exports a minimal set of functions, including `set()`, and the `cons()` constructor.

Plots are constructed using the `cons(:plot, ...` method:
```julia
plot = cons(:plot, nstrips = 3,
   #Add more properties such as axis labels here
)
```

Note that `EasyPlot` supports the concept of multiple y-strips tied a single x-axis (`nstrips = 3`).

`Waveforms` (`y` vs `x` data) are then added to this using `push!()`:
```julia
push!(plot,
    cons(:wfrm, signal, label="signal", strip=1),
    cons(:wfrm, signal_norm, label="||signal||", strip=2),
    cons(:wfrm, rate, label="d{signal}/dt", strip=3),
)
```

Before displaying `plot`, it is necessary to `push!()` it to a multi-plot collection:
```julia
plotset1 = push!(cons(:plotcoll, title="Parametric sin() - Observations"), plot)
```

Plots are finally shown on a plotting backend that implements an `EasyPlotDisplay<:Base.AbstractDisplay` interface:
```julia
CMDimData.@includepkg EasyPlotInspect
pdisp = EasyPlotInspect.PlotDisplay() #::EasyPlotDisplay
display(pdisp, plotset1)
```

Please note that plotting backends like `EasyPlotInspect` are currently "included" in the current module.  This is not ideal.

Nonetheless, code inclusion allows the backend modules to be bundled with the `CMDimData.jl` repository without adding all plotting packages to its dependency list. This would cause Julia to install more packages than you want/need.

As a result, you must *explicitly* add the plotting packages you desire to your *own* project's list of available packages.

## That's it!
A more complete version of this example is found in [parametric\_sin.jl](parametric_sin.jl).
