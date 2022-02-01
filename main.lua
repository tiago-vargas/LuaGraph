-- Exp = "(x-1)^2/2"
Function = require("Function")

-- Domain = {}
-- Graph = {}
Origin = {}
Scale  = {}

Viewport = {}

-- Default = {
-- 	-- color
-- }


function dist(P, Q)
	return math.sqrt( (P.x - Q.x)^2 + (P.y - Q.y)^2 )
end


function F(x, func)
	local exp = func:gsub("x", x)
	return load("return " .. exp)()
end

local function drawaxis(origin, screen_width, screen_height)
	-- draws 0x and 0y axis centered in `origin`
	love.graphics.line(0, origin.y, screen_width,  origin.y) -- Ox
	love.graphics.line(origin.x, 0, origin.x, screen_height) -- Oy
	-- return Ox, Oy
end

function love.load(args)
	Viewport.width, Viewport.height = love.graphics.getDimensions()
	Origin = { x = Viewport.width/2, y = Viewport.height/2 }
	Scale  = { Lx = 50, Ly = 50 }

	-- [[   TEST   ]] --
	f = Function.New()
	f.exp = "(x-1)^2/2"
	f:setDomain(-3, 3, 600)

	g = Function.New()
	g.exp = "math.sin(x)"
	g:setDomain(-3, 3, 600)
	-- f:computeCOM()
	-- [[ END TEST ]] --

	d = 4
end

function love.update(dt)
	-- -- [[   TEST   ]] --
	-- f:computeGraph(F)
	-- f.graph = f.graph * Scale
	-- -- f:computeCOM() -- doesn't work here, but compiles...
	-- -- [[ END TEST ]] --

	for i = 1, #Function.instances do
		local f = Function.instances[i]
		f:computeGraph(F)
		f.graph = f.graph * Scale
		-- f:computeCOM()
	end

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
	drawaxis({ x = Origin.x, y = Origin.y }, Viewport.width, Viewport.height)

	-- f:plot()
	-- f:computeCOM()
	-- f:drawCOM()

	for i = 1, #Function.instances do
		local f = Function.instances[i]
		f:plot()
		f:computeCOM()
		f:drawCOM()
	end
end

function love.keypressed(key)
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
