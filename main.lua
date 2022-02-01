-- Exp = "(x-1)^2/2"
local Function = require("Function")

-- Domain = {}
-- Graph = {}
Origin = {}
Scale = {}

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
	local Ox = love.graphics.line(0, origin.y, screen_width,  origin.y)
	local Oy = love.graphics.line(origin.x, 0, origin.x, screen_height)
	return Ox, Oy
end

function love.load(args)
	Viewport.width, Viewport.height = love.graphics.getDimensions()
	Origin = {x = Viewport.width/2, y = Viewport.height/2}
	Scale = {Lx = 50, Ly = 50}

	f = Function.New()
	f.exp = "(x-1)^2/2"
	f:setDomain(-3, 3, 600)
	-- f:getCOM()

	d = 4
end

function love.update(dt)
	f:setGraph(F)
	f.graph = f.graph * Scale
	-- f:getCOM() -- doesn't work here, but compiles...

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
	drawaxis({x = Origin.x, y = Origin.y}, Viewport.width, Viewport.height)
	f:plot()
	f:getCOM()
	f:printCOM()
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
