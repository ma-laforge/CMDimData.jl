<!-- Reference-style links to make tables & lists more readable -->
[Gallery]: <https://github.com/ma-laforge/FileRepo/blob/master/CMDimData>
[GallerySProc]: <https://github.com/ma-laforge/FileRepo/tree/master/SignalProcessing/sampleplots/README.md>
[GalleryInspectDR]: <https://github.com/ma-laforge/FileRepo/tree/master/InspectDR/sampleplots/README.md>
[MDDatasetsJL]: <https://github.com/ma-laforge/MDDatasets.jl>


# CMDimData.jl: Parametric Analysis +Continuous <var>f(x)</var> +Plotting
**Galleries:** [:art: sample output][Gallery] / [:art: CMDimCircuits.jl/SignalProcessing][GallerySProc] / [:art: InspectDR.jl package][GalleryInspectDR]

&mdash; ***"Focus on the analysis itself, not on data manipulation"***<br>
&mdash; ***"The hardest part of data analysis should be annotating the plots!"***

[![Build Status](https://github.com/ma-laforge/CMDimData.jl/workflows/CI/badge.svg)](https://github.com/ma-laforge/CMDimData.jl/actions?query=workflow%3ACI)

| <img src="https://github.com/ma-laforge/FileRepo/blob/master/CMDimData/parametric_sin_live/phi_all-A_all.png" width="850"> |
| :---: |

## &#x1F389; Now supporting plot builder files

Supports separate `.jl` files to build plots from user-provided data.
 - Specify titles, labels, linestyles, etc. for entire `PlotCollection` (multi-plot object) in a separate file.
 - Makes for more readable code.

See `EasyPlot.load_plotbuilders()` function (TODO: add to docs, currently only in [parametric\_sin.md](sample/analysis_fmtfiles/parametric_sin.md) sample).

## Table of contents

 1. [Description](#Description)
    1. [Features/Highlights](#Highlights)
 1. [Installation](#Installation)
 1. [Julia tips](doc/juliatips.md)
 1. [Programming interface](doc/api.md)
    1. [Plotting interface](doc/EasyPlot.md)
       1. [Plotting backends](doc/EasyPlot_backends.md)
    1. [Saving/Loading {data/plot} &hArr; HDF5 file](doc/EasyData.md)
 1. [Sample usage](#SampleUsage)
    1. [Sample directory](sample)
    1. [Live-slice examples](sample/LiveSlice)
    1. [Parametric `sin()` "simulation"](sample/analysis_fmtfiles/parametric_sin.md)
 1. [Known limitations](#KnownLimitations)

<a name="Description"></a>
## Description

CMDimData.jl provides a high-level abstraction to manipulate multi-dimensional data, and automatically interpolate intermediate values as if it was a continuous function.

The goal is to provide analysis tools that lead to minimal code, written in a *natural*, and *readable* fashion.

<a name="Highlights"></a>
### Features/Highlights

 1. Seamlessly handle multi-dimensional datasets with [MDDatasets.jl][MDDatasetsJL]
    - Perform the same operation on all elements (usually) without having to write explicit loops.
    - Results of data reductions (ex: `minimum()`, integrations, ...) are handled the same as any other data.
 1. Easily plot multi-dimensional results with [`EasyPlot` module](doc/EasyPlot.md).
    - Quickly organize and plot the results in a way that sheds light on the studied phenomenon.
    - Support for multiple [backends](doc/EasyPlot_backends.md)
    - Generate eye diagrams (even for backends without native support).
 1. Read/write plots to HDF5 files with [`EasyData` module](doc/EasyData.md).

<a name="Installation"></a>
## Installation

`CMDimData.jl` is registered with Julia's **General** registry.
It can be installed using Julia's built-in package manager:

```julia-repl
julia> ]
pkg> add CMDimData
pkg> add MDDatasets
```

Note that `MDDatasets.jl` will automatically be installed alongside `CMDimData.jl`.  However, `add`-ing it explicitly gives code from the active project/environment direct access to its features.

Moreover, it is highly suggested to install `InspectDR.jl`. It is the most tested integration for plotting at the moment:

```julia-repl
julia> ]
pkg> add InspectDR
```

<a name="SampleUsage"></a>
## Sample usage
Examples of how to use `CMDimData` are provided in the [sample/](sample) subdirectory.

A few examples are organized by function:
 - Sample plots: [sample/plots/](sample/plots)
 - "Live-Slice" examples: [sample/LiveSlice/](sample/LiveSlice)

Detailed walthroughs:
 - Parametric `sin()` "simulation": [sample/analysis\_fmtfiles/parametric\_sin.md](sample/analysis_fmtfiles/parametric_sin.md)

### Sample plot construction
More elaborate examples of constructing `EasyPlot.Plot`/`PlotCollection` objects can be found in the [sample/plots/](sample/plots/) folder.

<a name="KnownLimitations"></a>
## Known limitations

### [TODO](TODO.md)

### Compatibility

Extensive compatibility testing of CMDimData.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-1.3.1

## Disclaimer

The CMDimData.jl module is not yet mature.  Expect significant changes.
