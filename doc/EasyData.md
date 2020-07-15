# EasyData.jl (+EasyDataHDF5 Output)

## Description

The EasyData.jl module provides a simple interface to read/write datasets and plots to files.

Examples of the EasyData.jl capabilities can be found under the [test directory](test/)

### Major Highlight: EasyDataHDF5 Output

EasyData.jl makes it easy to write `CMDimData.EasyPlot.Plot` objects to HDF5 files.  With the help of the HDF5 file format, EasyDataHDF5 files embed both the data, and a description of the plot sturcture in one convenient file.

## Known Limitations

 - The EasyDataHDF5 format is still in the experimental phase.  It is not yet stable, and prone to major re-structuring.
 - There is currently no versionning of EasyDataHDF5 files.
  - Without versioning, EasyDataHDF5 files cannot easily be re-loaded - and therefore not the best choice for archival purposes.  That being said, with an HDF5 viewer, the format can probably be figured out with relative ease.

