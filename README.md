# EasySave.jl (+EasyPlotHDF5 Output)

## Description

The EasySave.jl module provides a simple interface to read/write datasets and plots to files.

Examples of the EasySave.jl capabilities can be found [here](sample/)

### Major Highlight: EasyPlotHDF5 Output

EasySave.jl makes it easy to write [EasyPlot](https://github.com/ma-laforge/EasyPlot.jl) objects to HDF5 files.  With the help of the HDF5 file format, EasyPlotHDF5 files embed both the data, and a description of the plot sturcture in one convenient file.

## Known Limitations

 - The EasyPlotHDF5 format is still in the experimental phase.  It is not yet stable, and prone to major re-structuring.
 - There is currently no versionning of EasyPlotHDF5 files.
  - Without versioning, EasyPlotHDF5 files cannot easily be re-loaded - and therefore not the best choice for archival purposes.  That being said, with an HDF5 viewer, the format can probably be figured out with relative ease.

### Compatibility

Extensive compatibility testing of EasySave.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.0

## Disclaimer

The EasySave.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
