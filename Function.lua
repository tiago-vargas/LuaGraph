local Function =
{
	instances = {},
	ID = 1
}

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
local function dist(P, Q)
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

--- Unpacks table of points `(x, y)` into a sequence { x1, y1, x2, y2, ... }
---
--- Returns this sequence
---
---@param graph table
---
---@return table coordinates_sequence
---
local function unpack_graph(graph)
	local coordinates = {}

	for i = 1, #graph do
		table.insert(coordinates, graph[i].x)
		table.insert(coordinates, graph[i].y)
	end

	return coordinates
end

--- Checks if a `n` is not `inf`, `-inf` nor `nan`
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
-----------------------
--[[ Class Methods ]]--
-----------------------

--- Creates a new instance of `Function`
---
--- Returns the instance
---
---@param exp   string # Function expression
---@param mode  string # `"cartesian"` | `"polar"`
---@param color table
---
---@return table instance
---
Function.New = function (exp, mode, color)
	local o  = {}
	setmetatable(o, mt)

	o.exp    = exp
	o.mode   = mode or "cartesian"
	o.domain = Function.CreateDomain(-10, 10, 1000)

	o.color  = color or Colors[Cor[ColorIndex]]
	o.id     = Function.ID
	ColorIndex = ColorIndex + 1

	Function.instances[Function.ID] = o
	Function.ID = Function.ID + 1

	return o
end

--- Creates a domain with ends on `a` and `b`, with `n` subdivisions,
--- e.g. `n = 2` means just the two endpoints
---
--- Returns the domain
---
---@param a number
---@param b number
---@param n number
---
---@return table domain
---
Function.CreateDomain = function (a, b, n)
	local domain = {}
	local dx = (b - a) / n

	for i = a, b, dx do
		table.insert(domain, i)
	end

	return domain
end

--#endregion


--#region object methods
------------------------
--[[ Object Methods ]]--
------------------------

--- Removes a function from the list of instances
Function.delete = function (self)
	Function.instances[self.id] = nil
	-- self = nil -- Seems to have no effect...
end

--- Draws the graph based on the function's mode
Function.plot = function (self)
	love.graphics.setColor(self.color)
	love.graphics.line(unpack_graph(self.graph + Origin))
end

--- Sets the domain from `a` to `b`, with `numpoints` points
---
---@param self table
---@param a number
---@param b number
---@param numpoints number
---
Function.setDomain = function (self, a, b, numpoints)
	self.domain = {}
	local dx = (b-a) / (numpoints-1)
	for i = a, b, dx do
		table.insert(self.domain, i)
	end
end

--- Computes the graph of a function based on its `domain` and sets it
---
--- The graph is a table of `(x, f(x))` elements
---
Function.computeGraph = function (self)
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
Function.computeGraphPolar = function (self)
	self.graph = {}
	setmetatable(self.graph, graph_mt)

	for i = 1, #self.domain do
		local x = self.domain[i]
		local p = evaluate(x, self.exp)
		self.graph[i] = { x = p*math.cos(x), y = -p*math.sin(x) }
	end
end

--- Computes the center of mass of a graph
Function.computeCOM = function (self)
	local Sx, Sy, L = 0, 0, 0

	for i = 1, #self.graph-1 do
		if is_number(self.graph[i].y) and is_number(self.graph[i+1].y) then
			local dL = dist(self.graph[i], self.graph[i+1])
			L  = L + dL
			Sx = Sx + self.graph[i].x * dL
			Sy = Sy + self.graph[i].y * dL
		end
	end

	self.com = { x = Sx/L, y = Sy/L }
end

--- Draws the center of mass of a graph
Function.drawCOM = function (self)
	love.graphics.setColor(self.color)
	love.graphics.circle("fill", self.com.x, self.com.y, 4)
end

--#endregion

-- [[ DEBUG ]] --
Function.ListInstances = function ()
	for k, v in pairs(Function.instances) do
		print(k, v.exp)
	end
end

return Function
