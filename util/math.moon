class Vec2
	new: (x, y) =>
		@self.x = x
		@self.y = y
		
	is_vec2: (v) -> (type v == table) and (v.__class == Vec2)

	__add: (other) =>
		assert Vec2.is_vec2 other, "add: Vec2 expected, got " .. type other
		Vec2(@x + other.x, @y + other.y)

	__sub: (other) =>
		assert Vec2.is_vec2 other, "sub: Vec2 expected, got " .. type other
		Vec2(@x - other.x, @y - other.y)

	__mul: (other) =>
		if Vec2.is_vec2 other
			Vec2(@x * other.x, @y * other.y) -- Dot product,
		else if type(other) == "number"
			Vec2(@x * other,   @y * other) -- Scalar multiplication.
		else
			error "mul: Vec2 or number expected, got " .. type other
	
	__tostring: => "Vec2(#{@x}, #{@y})"

---

{ :Vec2 }