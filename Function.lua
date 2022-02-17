-- local Editor = require("Editor")

local Function = {}

-----------------------------------------------
--[[ Auxiliary functions                   ]]--
-----------------------------------------------

local function distance(P, Q)
	local dx = P.x - Q.x
	local dy = P.y - Q.y

	return math.sqrt( dx ^ 2 + dy ^ 2 )
end

local function eval(expression)
	return load("return " .. expression)()
end

local function treat_expression(pretty_exp)
	local math_exp

	math_exp = pretty_exp:gsub("sin",  "math.sin")
	math_exp = math_exp:gsub("cos",  "math.cos")
	math_exp = math_exp:gsub("tan",  "math.tan")
	math_exp = math_exp:gsub("sqrt", "math.sqrt")
	math_exp = math_exp:gsub("PI",   "math.pi")
	math_exp = math_exp:gsub("abs",  "math.abs")

	return math_exp
end

Function.treatExpression = function (self)
	self.math_exp = treat_expression(self.pretty_exp)
end

local function is_number(n)
	if n ~= 1/0 and n ~= -1/0 and n == n and n ~= nil then
		return true
	end

	return false
end

local function apply_to_self(self, value)
	local exp = self.math_exp:gsub("x", value)
	return eval(exp)
end

local function translate_graph(graph, vector)
	for i = 1, #graph do
		graph[i].x = graph[i].x + vector.x
		graph[i].y = graph[i].y + vector.y
	end
	return graph
end

local function scale_graph(graph, factor)
	for i = 1, #graph do
		graph[i].x = graph[i].x * factor
		graph[i].y = graph[i].y * factor
	end
	return graph
end


--===========================================--
--[[ `Function` class                      ]]--
--===========================================--

local mt = { __index = Function, __call = apply_to_self }

local graph_mt = { __mul = scale_graph, __add = translate_graph }


-----------------------------------------------
--[[ Class Methods                         ]]--
-----------------------------------------------

--- Returns an instance of `Function`
---
---@param pretty_exp   string # Function expression
---@param mode  string # `"cartesian"` | `"polar"`
---
---@return table instance
---
Function.New = function (pretty_exp, mode)
	local o  = {}
	setmetatable(o, mt)

	o.pretty_exp  = pretty_exp  or "x"
	o.mode = mode or "cartesian"
	o.isVisible = true
	-- o:treatExpression()
	o.math_exp = treat_expression(pretty_exp)

	return o
end


-----------------------------------------------
--[[ Object Methods                        ]]--
-----------------------------------------------

--- Computes the graph of a function based on its `domain` and sets it
---
--- The graph is a table of `(x, f(x))` elements
---
Function.computeCartesianGraph = function (self)
	for i = 1, #self.domain do
		local xi = self.domain[i]
		self.graph[i] = { x = xi, y = -self(xi) }
	end
end

--- Computes the graph of a function in polar coordinates based on its `domain` and sets it
---
--- The graph is a table of `( p(t) cos(t), p(t) sin(t) )` elements
---
Function.computePolarGraph = function (self)
	for i = 1, #self.domain do
		local t = self.domain[i]
		local p = self(t)
		self.graph[i] = { x = p*math.cos(t), y = -p*math.sin(t) }
	end
end

Function.computeGraph = function (self)
	self.graph = {}
	setmetatable(self.graph, graph_mt)

	if self.mode == "cartesian" then
		self:computeCartesianGraph()
	elseif self.mode == "polar" then
		self:computePolarGraph()
	end
end

Function.computeCOM = function (self)
	local Sxdl, Sydl, L = 0, 0, 0
	local graph = self.graph
	local n = #graph - 1

	for i = 1, n do
		local P = graph[i]
		local Q = graph[i + 1]
		if is_number(P.y) and is_number(Q.y) then
			local dLi = distance(P, Q)
			local xmi = (P.x + Q.x) / 2
			local ymi = (P.y + Q.y) / 2

			L = L + dLi
			Sxdl = Sxdl + xmi * dLi
			Sydl = Sydl + ymi * dLi
		end
	end

	self.com = { x = Sxdl/L, y = Sydl/L }
end

return Function
