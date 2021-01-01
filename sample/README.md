# CMDimData.jl: `sample/` subdirectories

## [`analysis_fmtfiles/`](analysis_fmtfiles/)
Contains examples on how to analyze phenomena with the help of `CMDimData`/`EasyPlot` where ***plots are formatted using `EasyPlot` "formatting files"***.
 - Examples mostly use `EasyPlotInspect`/`InspectDR`.

## [`analysis_fmtinline/`](analysis_fmtinline/)
Contains examples on how to analyze phenomena with the help of `CMDimData`/`EasyPlot` where ***plots are formatted using inline code***.
 - Examples mostly use `EasyPlotInspect`/`InspectDR`.
 - User is encouraged to use ***formatting files*** instead of inline code to make analysis more readable.

## [`EasyPlotGrace/`](EasyPlotGrace/)
Examples using `Grace` backend specifically.

## [`EasyPlotInspect/`](EasyPlotInspect/)
Examples using `InspectDR` backend specifically.

## [`EasyPlotMPL/`](EasyPlotMPL/)
Examples using `PyPlot` backend specifically.

## [`EasyPlotPlots/`](EasyPlotPlots/)
Examples using `Plots.jl` backend specifically.

## [`LiveSlice/`](LiveSlice/)
Examples of "LiveSlice" concept in action.

## [`plots/`](plots/)
A collection of sample plots used in various examples.

# CMDimData.jl: `sample/` directory

## [runsamples_EasyData.jl](runsamples_EasyData.jl)

 1. For each sample plot in the [`plots/`](plots/) subdirectory:
    1. Load & display plot.
    1. Write plot to an .hdf5 file.
    1. Re-load .hdf5 plot to Julia.
    1. Display re-loaded .hdf5 file for comparison.
