module LiveSlice

using Interact
using Blink
using CMDimData
using CMDimData.EasyPlot
using MDDatasets


struct SliceParam
	sweep::PSweep
	choosevalue::Observable
	sweepindex::Observable
end

#==Helper functions
===============================================================================#
_throt(x) = throttle(0.1, x) #Default throttling of inputs for this tool.

#Sweep value string
_swvalstr(x::Int) = string(x)
_swvalstr(x::Float64) = EasyPlot.SI(x)


#==Main autoslice() function
===============================================================================#
"""
    autoslice(refreshfn, refparamlist::Vector{PSweep}, slicewfrmlist::Vector{Waveform})

Automatically updates provided waveforms, and calls provided function to refresh plots

#Arguments
 - refreshfn: Function to be called when caller should refresh plots
 - refparamlist: List of parameters to use to slice input data
 - slicewfrmlist: List of DataHR-waveforms to be sliced along different parameter dimensions
"""
function autoslice(refreshfn::Function, refparamlist::Vector{PSweep}, slicewfrmlist::Vector{EasyPlot.Waveform})
	origdatalist = DataHR[wfrm.data for wfrm in slicewfrmlist] #Only supports DataHR
	paramlist = SliceParam[]
	obslist = Observable[] #Index into each parameter sweep value
	widgetlist = [] #To be displayed in Blink

	#Build observables & sliders for each parameter provided by caller:
	for p in refparamlist
		choosevalue = Observable(true)
		sweepindex = Observable(1)
		push!(paramlist, SliceParam(p, choosevalue, sweepindex))
		push!(obslist, choosevalue)
		push!(obslist, _throt(sweepindex)) #Throttle observables to reduce load
		cb = checkbox(choosevalue)
		sld = slider(1:length(p.v), value=sweepindex, label=p.id)
		push!(widgetlist, hbox(cb, sld))
	end

	#Build up an expression string to see which parameter values we are selecting:
	_paramlist_str = map(obslist...) do varlist...
		isfirst = true
		paramstr = ""

		for p in paramlist
			if !isfirst
				paramstr *= " / "
			end
			valstr = "ALL"
			if p.choosevalue[]
				i = p.sweepindex[]
				valstr = _swvalstr(p.sweep.v[i])
			end
			paramstr *= p.sweep.id * "=" * valstr
			isfirst=false
		end
		return HTML(paramstr)
	end
	push!(widgetlist, _paramlist_str)

	#Swap out waveform data with a sliced version (dep. on slider values):
	_updater = map(obslist...) do varlist...
		for (od, wfrm) in zip(origdatalist, slicewfrmlist)
			idxlen = length(size(od.elem))
			Δidxlen = idxlen - length(paramlist)
			idxlist = fill!(Array{Any}(undef, idxlen), :)
			swlist = PSweep[]
			for (i, p) in enumerate(paramlist)
				if p.choosevalue[] #Want a specific index, not all swept values
					idxlist[i] = p.sweepindex[]
				else
					push!(swlist, p.sweep)
				end
			end
			append!(swlist, od.sweeps[(end+1-Δidxlen):end])
			newelem = od.elem[idxlist...]
			wfrm.data = DataHR(swlist, newelem)
		end
		refreshfn() #Ask user to refresh plots, etc
	end

	#Display main window:
	wnd = Window()
	body!(wnd, vbox()) #first call to body! does not always work.
	body!(wnd, hbox(vbox(widgetlist...), nothing))
	return
end

end #module
