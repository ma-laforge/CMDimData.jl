# Integrate MDDatasets.jl into this repository.

# Add functionality
 - `EASYPLOTINSPECT_RENDERW/H`: specify default dimensions to render plots with environment variable.
 - Plotting backends: GR, Grace, PyPlot, Plots.jl, Qwt.

### Remove/rename components
 - EasyPlot\*, EasyData, 
 - :HACK_SHOWTOUNFREEZE

### Package up contents of subpkgs/
Subpackages should be imported with `import EasyPlotInspect` instead of `@includepkg :EasyPlotInspect`.

Current solution does not support precompilation, and causes code duplication.  There are probably other side effects if that code is imported multiple times in different module namespaces (because types of same name don't technically refer to the same type, since they were "instantiated" multiple times).

Must first register subpackages using new system.

Change `using CMDimData.Colors` -> `using Colors` statements in all `subpkgs/` once this is done.

### Consolidate sample files

### Test plot write/read with actual images

Compare input and output plots using a plotting backend that actually runs on CI.
