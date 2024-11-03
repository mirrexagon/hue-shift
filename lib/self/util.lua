-- Utility functions
function printf(s,...)
  print(string.format(s,...))
end

function errorf(s,...)
  error(string.format(s,...))
end

function setIfNil(t,kv)
  for k,v in pairs(kv) do
    if not t[k] then
      t[k] = v
    end
  end
end

function table.clone(t)
  local c = {}
  for k,v in pairs(t) do
    c[k] = v
  end
  return t
end

function math.range(l,n,u)
  return (n >= l) and (n <= u)
end

function math.clamp(low, n, high)
  return math.min(math.max(n, low), high)
end

function math.sign(n)
  if n == 0 then
    return 0
  else
    return n/math.abs(n)
  end
end
