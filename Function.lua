local Function = {}

Function.instances = {}

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
Function.New = function (exp)
	local o  = {}
	o.exp    = exp
	-- setmetatable(o, Function.metatables)
	o.plot      = Function.Plot
	o.setDomain = Function.SetDomain
	o.computeGraph  = Function.ComputeGraph
	o.computeCOM    = Function.ComputeCOM
	o.drawCOM  = Function.DrawCOM
	table.insert(Function.instances, o)
	return o
end

--[[ Draws the graph ]]
Function.Plot = function (self)
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

	self.com = {x = Sx / L, y = Sy / L}
end

Function.DrawCOM = function (self)
	love.graphics.circle("fill", self.com.x, self.com.y, 4)
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

return Function
