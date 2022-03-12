local c_add = function (z1, z2)
	return {a = z1.a + z2.a, b = z1.b + z2.b}
end

local c_tostring = function (z)
	return z.a .. " + " .. z.b .. "i"
end

local c_index = function (table, key)
	return Z.prototype[key]
end

local metat = {__add = c_add, __tostring = c_tostring}

Z = {}
Z.prototype {
	j = "cas"
}


function Z.New(a, b)
	local o = {a = a, b = b}
	setmetatable(o, metat)
	return o
end

local z = Z.New( 2, 3)
local w = Z.New(-1, 4)
local x = Z.New()

print(x.j)
