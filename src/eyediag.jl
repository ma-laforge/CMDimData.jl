#EasyPlot Eye diagram utilities
#-------------------------------------------------------------------------------

#==NOTE:
This module includes tools to use in case the plotting (rendering) tool does
not support eye-diagrams directly.==#


#==Types
===============================================================================#
type DataEye <: MDDatasets.LeafDS
	data::Vector{DataF1}
end
DataEye() = DataEye(DataF1[])
#"Unofficially" register DataEye (not really recognized by MDDatasets):
MDDatasets.elemallowed(::Type{DataMD}, ::Type{DataEye}) = true

#TODO: kwargs tbit, teye
function BuildEye{TX<:Number, TY<:Number}(d::DataF1{TX,TY}, tbit::Number, teye::Number; tstart::Number=0)
	eye = DataEye()
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

#TODO: kwargs tbit, teye
function BuildEye(d::DataHR{DataF1}, tbit::Number, teye::Number; tstart::Number=0)
	eye = DataHR{DataEye}(d.sweeps)
	for coord in subscripts(eye)
		eye.subsets[coord...] = BuildEye(d.subsets[coord...], tbit, teye, tstart=tstart)
	end
	return eye
end

#Last line
