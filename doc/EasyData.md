# `CMDimData.EasyData` {Data/Plot} &hArr; HDF5 file

## Description

`CMDimData.EasyPlot` provides a simple interface to read/write datasets and plots to files.

Examples of the `CMDimData.EasyPlot` capabilities can be found under the [/sample](../sample/) directory.

### Major Highlight: EasyDataHDF5 Output

EasyData.jl makes it easy to:
 - Read/write `CMDimData.EasyPlot.Plot` objects to/from a single HDF5 file.
 - Read/write multi-dimensional datasets (`T<:MDDatasets.DataMD`) to/from a single HDF5 file.
   - Including: `DataF1`, `DataRS`, and also the semi-deprecated `DataHR` format.

The flexibility of the HDF5 file format makes it simple to store both the data, and the plot structure in one convenient file.

## Known Limitations

 - The EasyDataHDF5 format is still in the experimental phase.  It is not yet stable, and prone to major re-structuring.
 - There is currently no versionning of EasyDataHDF5 files.
  - Without versioning, EasyDataHDF5 files cannot easily be re-loaded if ever the format changes.  Consequently, it is not the best choice for archival purposes.  That being said, with an HDF5 viewer, the format can probably be figured out by simple inspection.

