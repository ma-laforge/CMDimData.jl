#EasyPlot Eye diagram utilities
#-------------------------------------------------------------------------------

#==NOTE:
This module includes tools to use in case the plotting (rendering) tool does
not support eye-diagrams directly.==#


#==Types
===============================================================================#
type EyeData <: MDDatasets.LeafDS
	data::Vector{DataF1}
end
EyeData() = EyeData(DataF1[])

#TODO: kwargs tbit, teye
function BuildEye{TX<:Number, TY<:Number}(d::DataF1{TX,TY}, tbit::Number, teye::Number; tstart::Number=0)
	eye = EyeData()
	x = d.x; y = d.y

	i = 1
	#skip initial data:
	while i <= length(x) && x[i] < tstart
		i+=1
	end
	wndnum = 0
	inext = i
	done = i > length(x)
	while !done
		istart = inext
		wndstart = tstart+wndnum*tbit
		nexteye = wndstart+tbit
		wndend = wndstart+teye
		while i <= length(x) && x[i] < nexteye
			i+=1
		end
		inext = i
		while i <= length(x) && x[i] < wndend
			i+=1
		end
		if i > length(x)
			i = length(x)
		end
		if i == istart; break; end #Nothing to add
		push!(eye.data, DataF1(x[istart:i].-wndstart,y[istart:i]))
		if inext > length(x); break; end #Nothing else
		wndnum += 1
	end
	return eye
end

#Last line
