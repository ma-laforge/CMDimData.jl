# EasyPlotQwt.jl

## Description

EasyPlotQwt.jl implements EasyPlot.Backend{:Qwt} using Matplotlib (PyPlot.jl).

## Installing Dependencies

Install sip & Qwt5 packages (make sure to have proper version of Python in your path):

		conda install sip
		conda install -c pkgw Qwt5

Download/install Pierre's Python libraries:

		git clone https://github.com/PierreRaybaut/guidata.git
		cd guidata; python setup.py install
		git clone https://github.com/PierreRaybaut/PythonQwt.git
		cd PythonQwt; python setup.py install
		git clone https://github.com/PierreRaybaut/guiqwt.git
		cd guiqwt; python setup.py build install

### Install issues

This installation appears to be able to break the Matplotlib/Pyplot Anaconda/Julia installation for some reason.  The fix was to re-install everything.

 1. Blow way the `~/.julia` subdirectory

 1. Remove Matplotlib:

		conda uninstall matplotlib

 1. Re-install Matplotlib:

		conda install matplotlib

 1. Re-install Julia libraries

		julia> Pkg.add("PyPlot")
		julia> Pkg.add("HDF5")
		...

## TODO

Create native Julia version.  Loading the Python environment is relatively slow.

## Known Limitations

### Compatibility

Extensive compatibility testing of EasyPlotQwt.jl has not been performed.  The module has been tested using the following environment(s):

 - Linux / Julia-0.4.0

## Disclaimer

The EasyPlotQwt.jl module is not yet mature.  Expect significant changes.

This software is provided "as is", with no guarantee of correctness.  Use at own risk.
