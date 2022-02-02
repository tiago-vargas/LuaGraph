local Function = {}

Function.instances = {}

Function.ID = 1

--[[ Prototype
Function.prototype = {
	plot      = Function.Plot,
	setDomain = Function.SetDomain,
	setGraph  = Function.SetGraph,
	getCOM    = Function.GetCOM,
	printCOM  = Function.PrintCOM
}
]]

--[[ Creates a new instance of `Function` ]]
Function.New = function (exp, mode, color)
	local o  = {}
	o.exp    = exp
	-- o.domain = domain
	if o.domain == nil then
		Function.SetDomain(o, -10, 10, 1000)
	end

	o.mode   = mode or "plane"

	o.color  = color or Colors[Cor[ColorIndex]]
	o.id     = Function.ID
	ColorIndex = ColorIndex + 1
	-- setmetatable(o, Function.metatables)
	o.plot          = Function.Plot
	o.setDomain     = Function.SetDomain
	o.computeGraph  = Function.ComputeGraph
	o.computeCOM    = Function.ComputeCOM
	o.drawCOM       = Function.DrawCOM
	o.delete        = Function.Delete

	o.computeGraphPolar  = Function.ComputeGraphPolar

	Function.instances[Function.ID] = o
	Function.ID = Function.ID + 1
	return o
end

Function.Delete = function (self)
	Function.instances[self.id] = nil
	-- self = nil
end

--[[ Draws the graph ]]
Function.Plot = function (self)
	love.graphics.setColor(self.color)
	love.graphics.line(Function.Unpackgraph(self.graph + Origin))
end

--[[ Creates a domain of values with ends in `a` and `b`, with `numpoints` points ]]
Function.SetDomain = function (self, a, b, numpoints)
	self.domain = {}
	local dx = (b-a) / (numpoints-1)
	for i = a, b, dx do
		table.insert(self.domain, i)
	end
end

Function.ComputeGraph = function (self, fun)
	self.graph = {}
	for i = 1, #self.domain do
		local x = self.domain[i]
		self.graph[i] = {x = x, y = -fun(x, self.exp)}
	end

	setmetatable(self.graph, Function.graph_metatables)
end

Function.ComputeCOM = function (self)
	local Sx, Sy, L = 0, 0, 0
	for i = 1, #self.graph-1 do
		local dL = dist(self.graph[i], self.graph[i+1])
		L = L + dL
		Sx = Sx + self.graph[i].x * dL
		Sy = Sy + self.graph[i].y * dL
	end

	self.com = { x = Sx/L, y = Sy/L }
end

Function.DrawCOM = function (self)
	love.graphics.setColor(self.color)
	love.graphics.circle("fill", self.com.x, self.com.y, 4)
end

Function.ComputeGraphPolar = function (self, fun)
	self.graph = {}
	for i = 1, #self.domain do
		local x = self.domain[i]
		local ro = fun(x, self.exp)
		self.graph[i] = {x = ro*math.cos(x), y = -ro*math.sin(x)}
	end

	setmetatable(self.graph, Function.graph_metatables)
end


Function.graph_metatables = {
	__mul = function (graph, transformation)
		for i = 1, #graph do
			graph[i].x = graph[i].x * transformation.Lx
			graph[i].y = graph[i].y * transformation.Ly
		end
		return graph
	end,

	__add = function (graph, point)
		for i = 1, #graph do
			graph[i].x = graph[i].x + point.x
			graph[i].y = graph[i].y + point.y
		end
		return graph
	end
}

-- Function.metatables = {
-- 	__index = Function.prototype
-- }

--[[ unpacks set of points into a sequence {x1, y1, x2, y2, ...} ]]
Function.Unpackgraph = function (graph)
	local coordinates = {}
	for i = 1, #graph do
		table.insert(coordinates, graph[i].x)
		table.insert(coordinates, graph[i].y)
	end

	return coordinates
end

-- [[ DEBUG ]] --
Function.ListInstances = function ()
	for k, v in pairs(Function.instances) do
		print(k, v.exp)
	end
end

return Function
