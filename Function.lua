-- local Editor = require("Editor")

local Function = {}

--#region auxiliary functions
-----------------------------------------------
--[[ Auxiliary functions                   ]]--
-----------------------------------------------

--- Returns the distance between two points
---
---@param P table # point (x, y)
---@param Q table # point (x, y)
---
---@return number distance
---
local function distance(P, Q)
	local dx = P.x - Q.x
	local dy = P.y - Q.y

	return math.sqrt( dx ^ 2 + dy ^ 2 )
end

--- Substitutes `x` for its value in an expression `funcexp`
---
--- Returns the evaluation
---
---@param x       number # the value to substitute
---@param funcexp string # the expression
---
---@return number evaluation
---
local function evaluate(x, funcexp)
	local exp = funcexp:gsub("x", x)
	--[[ Sketch
	exp = exp:gsub("sin",  "math.sin")
	exp = exp:gsub("cos",  "math.cos")
	exp = exp:gsub("tan",  "math.tan")
	exp = exp:gsub("sqrt", "math.sqrt")
	exp = exp:gsub("pi",   "math.pi")
	]]
	return load("return " .. exp)()
end

--- Checks if a `n` is not `inf`, `-inf`, `nan` nor `nil`
---
---@param n number
---
---@return boolean
---
local function is_number(n)
	if n ~= 1/0 and n ~= -1/0 and n == n and n ~= nil then
		return true
	end

	return false
end
--#endregion


--===========================================--
--[[ `Function` class                      ]]--
--===========================================--

local mt = { __index = Function }

local graph_mt =
{
	--- Applies a linear trasformation* on a graph
	__mul = function (graph, scale)
		for i = 1, #graph do
			graph[i].x = graph[i].x * scale
			graph[i].y = graph[i].y * scale
		end
		return graph
	end,

	--- Translates a graph in the direction of `vector`
	---
	--- Returns the translated graph
	---
	---@param graph  table
	---@param vector table
	---
	---@return table translated_graph
	---
	__add = function (graph, vector)
		for i = 1, #graph do
			graph[i].x = graph[i].x + vector.x
			graph[i].y = graph[i].y + vector.y
		end
		return graph
	end
}


--#region class methods
-----------------------------------------------
--[[ Class Methods                         ]]--
-----------------------------------------------

--- Creates a new instance of `Function`
---
--- Returns the instance
---
---@param exp   string # Function expression
---@param mode  string # `"cartesian"` | `"polar"`
---
---@return table instance
---
Function.New = function (exp, mode)
	local o  = {}
	setmetatable(o, mt)

	o.exp     = exp  or "x"
	o.mode    = mode or "cartesian"
	-- o.visible = true

	return o
end


--#region object methods
-----------------------------------------------
--[[ Object Methods                        ]]--
-----------------------------------------------

--- Computes the graph of a function based on its `domain` and sets it
---
--- The graph is a table of `(x, f(x))` elements
---
Function.computeCartesianGraph = function (self)
	self.graph = {}
	setmetatable(self.graph, graph_mt)

	for i = 1, #self.domain do
		local x = self.domain[i]
		self.graph[i] = { x = x, y = -evaluate(x, self.exp) }
	end
end

--- Computes the graph of a function in polar coordinates based on its `domain` and sets it
---
--- The graph is a table of `(p cos(t), p sin(t))` elements
---
Function.computePolarGraph = function (self)
	self.graph = {}
	setmetatable(self.graph, graph_mt)

	for i = 1, #self.domain do
		local x = self.domain[i]
		local p = evaluate(x, self.exp)
		self.graph[i] = { x = p*math.cos(x), y = -p*math.sin(x) }
	end
end

Function.computeGraph = function (self)
	if self.mode == "cartesian" then
		self:computeCartesianGraph()
	elseif self.mode == "polar" then
		self:computePolarGraph()
	end
end

--- Computes the center of mass of a graph
Function.computeCOM = function (self)
	local Sx, Sy, L = 0, 0, 0
	local graph = self.graph

	for i = 1, #graph-1 do
		local P = graph[i]
		local Q = graph[i + 1]
		if is_number(P.y) and is_number(Q.y) then
			local dL = distance(P, Q)
			L  = L + dL
			Sx = Sx + P.x * dL
			Sy = Sy + P.y * dL
		end
	end

	self.com = { x = Sx/L, y = Sy/L }
end
--#endregion

return Function
