#Demo 4: Test write/read of misc. plot attributes
#-------------------------------------------------------------------------------

using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
CMDimData.@includepkg EasyData


#==Generate plots
===============================================================================#
#Load sample plot:
filelist = EasyPlot.demofilelist()
plot = evalfile(filelist[1]);

filepath ="./sampleplot4.hdf5"
EasyData._write(filepath, plot)
plot2 = EasyData._read(filepath, EasyPlot.Plot);
set(plot2, title="Compare results")


#==Show results
===============================================================================#
[plot, plot2]
