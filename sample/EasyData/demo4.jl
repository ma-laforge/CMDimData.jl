#Demo 4: Test write/read of misc. plot attributes
#-------------------------------------------------------------------------------

using FileIO2
using MDDatasets
using EasyPlot
using EasyData


#==Generate plots
===============================================================================#
#Load sample plot:
plot = evalfile(EasyPlot.sampleplotfile(1));

filepath ="./sampleplot4.hdf5"
EasyData._write(filepath, plot)
plot2 = EasyData._read(filepath, EasyPlot.Plot);
set(plot2, title="Compare results")


#==Show results
===============================================================================#
[plot, plot2]
