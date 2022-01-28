Exp = "x"
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

F_metatables = {
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

Function = {
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

	-- New = function (exp, domain)
	-- 	local o  = {}
	-- 	o.exp    = exp
	-- 	o.domain = domain
	-- 	-- o.graph  = graph
	-- 	-- o.color  = color
	-- 	o.plot = Function.Plot
	-- 	setmetatable(o.graph, F_metatables)
	-- 	return o
	-- end

	Plot = function (graph)
		--[[ Draws the graph ]]
		love.graphics.line(unpackgraph(graph + Origin))

	end,

	NewDomain = function (a, b, numpoints)
		--[[ creates a domain of values with ends in `a` and `b`, with `numpoints` points ]]
		local domain = {}
		local dx = (b-a) / (numpoints-1)
		for i = a, b, dx do
			table.insert(domain, i)
		end

		return domain
	end,

	NewGraph = function (domain, fun)
		local graph = {}
		for i = 1, #domain do
			local x = domain[i]
			graph[i] = {x = x, y = -fun(x, Exp)}
		end

		return graph
	end
}

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
	Scale = {Lx = 1, Ly = 1}

	Domain = Function.NewDomain(-50, 50, 100)

	d = 4
end

function love.update(dt)
	Graph = Function.NewGraph(Domain, F)
	setmetatable(Graph, F_metatables)
	Graph = Graph * Scale

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
	-- love.graphics.points(Graph)
	Function.Plot(Graph)
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
