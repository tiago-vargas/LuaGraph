local Function = {}

-----------------------------------------------
--[[ Auxiliary functions                   ]]--
-----------------------------------------------

local function distance(P, Q)
	local dx = P.x - Q.x
	local dy = P.y - Q.y

	return math.sqrt( dx ^ 2 + dy ^ 2 )
end

local function evaluate(expression)
	return load("return " .. expression)()
end

local function treat_expression(pretty_exp)
	local math_exp

	math_exp = pretty_exp:gsub("sin",  "math.sin")
	math_exp = math_exp:gsub("cos",  "math.cos")
	math_exp = math_exp:gsub("tan",  "math.tan")
	math_exp = math_exp:gsub("sqrt", "math.sqrt")
	math_exp = math_exp:gsub("abs",  "math.abs")
	math_exp = math_exp:gsub("exp",  "math.exp")
	math_exp = math_exp:gsub("ln",   "math.log")
	math_exp = math_exp:gsub("log",  "math.log10")
	math_exp = math_exp:gsub("pow",  "math.pow")
	math_exp = math_exp:gsub("PI",   "math.pi")

	return math_exp
end

local function is_number(n)
	if n ~= 1/0 and n ~= -1/0 and n == n and n ~= nil then
		return true
	end

	return false
end

local function apply_to_self(self, value)
	local exp = self.mathExp:gsub("x", value)
	return evaluate(exp)
end

local function translate_graph(graph, vector)
	local new_graph = {}

	for i = 1, #graph do
		new_graph[i] =
		{
			x = graph[i].x + vector.x,
			y = graph[i].y + vector.y
		}
	end
	return new_graph
end

local function scale_graph(graph, factor)
	local new_graph = {}
	setmetatable(new_graph, { __add = translate_graph })

	for i = 1, #graph do
		new_graph[i] =
		{
			x = graph[i].x *  factor,
			y = graph[i].y * -factor
		}
	end
	return new_graph
end


-----------------------------------------------
--[[ Class Methods                         ]]--
-----------------------------------------------

Function.New = function (pretty_exp, mode)
	local o  = {}
	setmetatable(o, { __index = Function, __call = apply_to_self })

	o.prettyExp = pretty_exp  or "x"
	o.mode      = mode or "cartesian"
	o.mathExp   = treat_expression(pretty_exp)

	return o
end


-----------------------------------------------
--[[ Object Methods                        ]]--
-----------------------------------------------

Function.computeCartesianGraph = function (self)
	for i, xi in pairs(self.domain) do
		local P = { x = xi, y = self(xi) }
		self.graph[i] = P
	end
end

Function.computePolarGraph = function (self)
	for _, theta in pairs(self.domain) do
		local ro = self(theta)
		local P  = { x = ro*math.cos(theta), y = ro*math.sin(theta) }
		table.insert(self.graph, P)
	end
end

Function.computeGraph = function (self)
	self.graph = {}
	setmetatable(self.graph, { __mul = scale_graph })

	if self.mode == "cartesian" then
		self:computeCartesianGraph()
	elseif self.mode == "polar" then
		self:computePolarGraph()
	end
end

Function.computeCOM = function (self)
	local Sxdl, Sydl, L = 0, 0, 0
	local graph = self.graph
	local n     = #graph - 1

	for i = 1, n do
		local P = graph[i]
		local Q = graph[i + 1]
		if is_number(P.y) and is_number(Q.y) then
			local dLi = distance(P, Q)
			local xmi = (P.x + Q.x) / 2
			local ymi = (P.y + Q.y) / 2

			L    = L + dLi
			Sxdl = Sxdl + (xmi * dLi)
			Sydl = Sydl + (ymi * dLi)
		end
	end

	self.com = { x = Sxdl/L, y = Sydl/L }
end

return Function
