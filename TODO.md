# Integrate MDDatasets.jl into this repository.

# Add functionality
 - `EASYPLOTINSPECT_RENDERW/H`: specify default dimensions to render plots with environment variable.
 - Plotting backends: GR, Grace, PyPlot, Plots.jl, Qwt.

# Remove/rename components
 - EasyPlot\*, EasyData, 
 - :HACK_SHOWTOUNFREEZE

# Package up contents of subpkgs/
Subpackages should be imported with `import EasyPlotInspect` instead of `@includepkg :EasyPlotInspect`.

Current solution does not support precompilation, and causes code duplication.  There are probably other side effects if that code is imported multiple times in different module namespaces (because types of same name don't technically refer to the same type, since they were "instantiated" multiple times).

Must first register subpackages using new system.

Change `using CMDimData.Colors` -> `using Colors` statements in all `subpkgs/` once this is done.

# Consolidate sample files

Create sample/plots/ploti.jl for sample plots

Create demoi_bkname.jl files specific to a particular backend to better illustrate how to use the module.

Make EasyData/runsamples.jl duplicate plots, instead of having evalfile() return an array of plots.

# Test plot write/read with actual images

Compare input and output plots using a plotting backend that actually runs on CI.

# Implement Themes
Untangle mess with color schemes, color managers, `getcolor`, `resolve*`, `mapcolor`, ...

 - Re-investigate `EasyPlot`: `ColorRef` vs `ColorRef_WFA`
 - Re-investigate `EasyPlot.ColorScheme`, `EasyPlot.WfrmAttributes`.
 - Consolidate `EasyPlot.WfrmAttributes` & `[backend].WfrmAttributes`: seems ugly to have two.
 - Investigate idea replacing `LineAttributes` & `GlyphAttributes` with WfrmAttributes ONLY.
   - Esp practical now that we have a better means of applying attributes with "line=set(...)", etc. Actual object hierarchy less critical now.
 - `WfrmAttributes`: mutable?
 - Re-investigate `EasyPlotGrace.ColorMgr`.
 - Re-investigate use of `nothing` for color. What about `:auto`, or a special julia type?
 - Differentiate `map*` vs `resolve*`.

Pass theme by argument?
 - Plot building function could be passed a theme when plot does not specify one.

When should themes be applied?
 - When building plot objects?
 - Just before building plot on a backend?
 - A combination of both?

Thought:
 - How to mirror `glyph.color` from `line.color` when `glyph.color==nothing` given that we
only now `line.color` after multi-dim datasets get split (just adding to plotting backend).

# Document backend-interface implementation
Explain how to create a module to interface with a new backend.

# Move module description to docs
Grab info from EasyPlot.jl, etc.

# Activate `VALID_*` values & perform validation

# Questionable Naming
`NullOr{T}`, ...

Rename `buildeye()`/`eye*`. Should be `fold*`.
