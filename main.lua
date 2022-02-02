Function = require("Function")
Colors   = require("Colors")

Origin = {}
Scale  = {}

Cor = {
	-- "Black",
	"Red",
	"Green",
	"Yellow",
	"Blue",
	"Purple",
	"Cyan",
	-- "White",
}
ColorIndex = 1

Viewport = {}

Default = {
	Color = Colors.Black,
	Background = Colors.BrightWhite
}


function dist(P, Q)
	return math.sqrt( (P.x - Q.x)^2 + (P.y - Q.y)^2 )
end


function F(x, func)
	local exp = func:gsub("x", x)
	return load("return " .. exp)()
end

--[[ draws 0x and 0y axes centered in `origin` ]]
local function drawaxis(origin, screen_width, screen_height)
	love.graphics.line(0, origin.y, screen_width,  origin.y) -- Ox
	love.graphics.line(origin.x, 0, origin.x, screen_height) -- Oy
end

function love.load(args)
	Viewport.width, Viewport.height = love.graphics.getDimensions()
	Origin = { x = Viewport.width/2, y = Viewport.height/2 }
	Scale  = { Lx = 50, Ly = 50 }
	love.graphics.setColor(Default.Color)
	love.graphics.setBackgroundColor(Default.Background)

-- [[   TEST   ]] --
	f = Function.New()
	f.exp = "(x-1)^2/2"
	-- f.color = Colors.BrightYellow
	f:setDomain(-3, 3, 600)

	g = Function.New("math.sin(x)")
	g.color = Colors.BrightRed
	g:setDomain(-3, 3, 600)
-- [[ END TEST ]] --

	d = 4
end

function love.update(dt)
	for i = 1, #Function.instances do
		local f = Function.instances[i]
		f:computeGraph(F)
		f.graph = f.graph * Scale
		-- f:computeCOM() -- doesn't work here, but compiles...
	end

	if     love.keyboard.isDown("up")    then
		Origin.y = Origin.y + d
	elseif love.keyboard.isDown("down")  then
		Origin.y = Origin.y - d
	end

	if     love.keyboard.isDown("left")  then
		Origin.x = Origin.x + d
	elseif love.keyboard.isDown("right") then
		Origin.x = Origin.x - d
	end
end

function love.draw()
	drawaxis({ x = Origin.x, y = Origin.y }, Viewport.width, Viewport.height)

	for i = 1, #Function.instances do
		local f = Function.instances[i]
		f:plot()
		f:computeCOM()
		f:drawCOM()
	end

	love.graphics.setColor(Default.Color)
end

function love.keypressed(key)
	if key == "\\"and love.keyboard.isDown("rctrl") then
		debug.debug()
	end

	if     key == "kp*" then
		Scale.Lx = Scale.Lx + 0.5
	elseif key == "kp/" then
		Scale.Lx = Scale.Lx - 0.5
	end

	if     key == "kp+" then
		Scale.Ly = Scale.Ly + 0.5
	elseif key == "kp-" then
		Scale.Ly = Scale.Ly - 0.5
	end
end
