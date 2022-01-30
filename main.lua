-- Exp = "(x-1)^2/2"
Origin = {}
Domain = {}
Graph = {}
Scale = {}

Viewport = {}

Default = {
	-- color
}

local function unpackgraph(graph)
	--[[ unpacks set of points into a sequence {x1, y1, x2, y2, ...} ]]
	local coordinates = {}
	for i = 1, #graph do
		table.insert(coordinates, graph[i].x)
		table.insert(coordinates, graph[i].y)
	end

	return coordinates
end

local function dist(P, Q)
	return math.sqrt( (P.x - Q.x)^2 + (P.y - Q.y)^2 )
end

-- metatables = {
-- 	__index = function (table, key)
-- 		return Function.prototype[key]
-- 	end
-- }

-------------------------------------------------------------------------------
--[[ NAMESPACE ]]
Function = {}
--[[
	expression
	domain
	graph
	color
	mode
	thickness
	c.o.m.
	roots
]]



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


--[[ Draws the graph ]]
Function.Plot = function (self)
	love.graphics.line(unpackgraph(self.graph + Origin))
end

--[[ Creates a domain of values with ends in `a` and `b`, with `numpoints` points ]]
Function.SetDomain = function (self, a, b, numpoints)
	self.domain = {}
	local dx = (b-a) / (numpoints-1)
	for i = a, b, dx do
		table.insert(self.domain, i)
	end
end

Function.SetGraph = function (self, fun)
	self.graph = {}
	for i = 1, #self.domain do
		local x = self.domain[i]
		self.graph[i] = {x = x, y = -fun(x, self.exp)}
	end

	setmetatable(self.graph, Function.graph_metatables)
end

Function.GetCOM = function (self)
	local Sx, Sy, L = 0, 0, 0
	for i = 1, #self.graph-1 do
		local dL = dist(self.graph[i], self.graph[i+1])
		L = L + dL
		Sx = Sx + self.graph[i].x * dL
		Sy = Sy + self.graph[i].y * dL
	end

	self.com = {x = Sx / L, y = Sy / L}
end

Function.PrintCOM = function (self)
	love.graphics.circle("fill", self.com.x, self.com.y, 4)
end

Function.prototype = {
	plot      = Function.Plot,
	setDomain = Function.SetDomain,
	setGraph  = Function.SetGraph,
	getCOM    = Function.GetCOM,
	printCOM  = Function.PrintCOM
}

Function.metatables = {
	__index = Function.prototype
}

--[[ Creates a new instance of `Function` ]]
Function.New = function (exp)
	local o  = {}
	o.exp    = exp
	setmetatable(o, metatables)
	-- o.plot      = Function.Plot
	-- o.setDomain = Function.SetDomain
	-- o.setGraph  = Function.SetGraph
	-- o.getCOM    = Function.GetCOM
	-- o.printCOM  = Function.PrintCOM
	return o
end


function F(x, func)
	local exp = func:gsub("x", x)
	return load("return " .. exp)()
end

local function drawaxis(origin, screen_width, screen_height)
	-- draws 0x and 0y axis centered in `origin`
	local Ox = love.graphics.line(0, origin.y, screen_width,  origin.y)
	local Oy = love.graphics.line(origin.x, 0, origin.x, screen_height)
	return Ox, Oy
end

function love.load(args)
	Viewport.width, Viewport.height = love.graphics.getDimensions()
	Origin = {x = Viewport.width/2, y = Viewport.height/2}
	Scale = {Lx = 50, Ly = 50}

	-- Domain = Function.SetDomain(-3, 3, 600)
	f = Function.New()
	f.exp = "(x-1)^2/2"
	f:setDomain(-3, 3, 600)

	d = 4
end

function love.update(dt)
	f:setGraph(F)
	f.graph = f.graph * Scale

	if love.keyboard.isDown("up") then
		Origin.y = Origin.y + d
	elseif love.keyboard.isDown("down") then
		Origin.y = Origin.y - d
	end

	if love.keyboard.isDown("left") then
		Origin.x = Origin.x + d
	elseif love.keyboard.isDown("right") then
		Origin.x = Origin.x - d
	end
end

function love.draw()
	-- love.graphics.setLineWidth(1)
	drawaxis({x = Origin.x, y = Origin.y}, Viewport.width, Viewport.height)
	f:plot()
	f:getCOM()
	f:printCOM()
end

function love.keypressed(key)
	-- print(key)

	if key == "\\" and love.keyboard.isDown("rctrl") then
		debug.debug()
	end

	if key == "kp*" then
		Scale.Lx = Scale.Lx + 0.5
	elseif key == "kp/" then
		Scale.Lx = Scale.Lx - 0.5
	end

	if key == "kp+" then
		Scale.Ly = Scale.Ly + 0.5
	elseif key == "kp-" then
		Scale.Ly = Scale.Ly - 0.5
	end
end
