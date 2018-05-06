clamp = (min, n, max) ->
    math.max (math.min n, max), min

linear_map = (n, in_min, in_max, out_min, out_max) ->
    (n - in_min) * (out_max - out_min) / (in_max - in_min) + out_min


{ :clamp, :linear_map }