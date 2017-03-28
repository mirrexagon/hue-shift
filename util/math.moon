linear_map = (n, in_min, in_max, out_min, out_max) ->
	(n - in_min) * (out_max - out_min) / (in_max - in_min) + out_min


{ :linear_map }