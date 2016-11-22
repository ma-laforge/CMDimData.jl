# EasyPlotQwt.jl

## Description

EasyPlotQwt.jl implements EasyPlot.EasyPlotDisplay using Qwt plot widgets (guiqwt).

## Installation

### guiqwt

Instructions on how to install guiqwt and its dependencies can be found here:

 1. [Install guiqwt](https://github.com/ma-laforge/HowTo/tree/master/guiqwt/guiqwt_install.md#Py27Installation)

## Points of Consideration

EasyPlotQwt.jl uses Python wrappers developped by Pierre Raybaut.  The principal dependency list is included below:

 - **guiqwt**: <https://github.com/PierreRaybaut/guiqwt>
 - **guidata**: <https://github.com/PierreRaybaut/guidata>
 - **PythonQwt**: <https://github.com/PierreRaybaut/PythonQwt>
 - **PyQwt**?: <http://pyqwt.sourceforge.net/home.html> (Authors?)
 - **Qwt**: <http://qwt.sourceforge.net/> (Uwe Rathmann - C++)

Would it be better to make use of the Qwt.jl library from Tom Breloff instead? The principal dependency list is included below:

 - **Qwt.jl**: <https://github.com/tbreloff/Qwt.jl>
 - **PyQwt**: <http://pyqwt.sourceforge.net/home.html> (Authors?)
 - **Qwt**: <http://qwt.sourceforge.net/> (Uwe Rathmann - C++)


That being said, it would be preferable to create native Julia version of the Qwt backend.  Loading the Python environment requires a noticeable overhead in time.

## Known Limitations

### Compatibility

Extensive compatibility testing of EasyPlotQwt.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.5.0 (64-bit)

#### Repository versions:

This code might not be using the most recent API of its dependencies.  The repository versions are included below:

 - **guidata**: Sat Dec 5 09:30:56 2015 +0100
 - **PythonQwt**: Tue Dec 8 16:55:50 2015 +0100
 - **guiqwt**: Thu Dec 3 15:52:16 2015 +0100

## Disclaimer

The EasyPlotQwt.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
