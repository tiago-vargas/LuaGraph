Function = require("Function")
Editor   = require("Editor")
Colors   = require("Colors")

Origin = {}

local Scale  = {}
local Viewport = {}

-- local Mode = "cartesian"

local Default =
{
	Mode       = "cartesian",
	Color      = Colors.Black,
	Background = Colors.BrightWhite,
	Scale      = 50,
}

--[[ draws 0x and 0y axes centered in `origin` ]]
local function draw_cartesian_axes(origin, screen_width, screen_height)
	love.graphics.line(0, origin.y, screen_width,  origin.y) -- Ox
	love.graphics.line(origin.x, 0, origin.x, screen_height) -- Oy
end

--[[ draws 0x polar axis centered in `origin` ]]
local function draw_polar_axes(origin, screen_width, screen_height)
	love.graphics.line(0, origin.y, screen_width,  origin.y) -- Ox
	love.graphics.line(origin.x, 0, origin.x, screen_height) -- Oy
end

function love.load(args)
	Viewport.width, Viewport.height = love.graphics.getDimensions()
	Origin = { x = Viewport.width/2, y = Viewport.height/2 }
	Scale  = Default.Scale
	love.graphics.setColor(Default.Color)
	love.graphics.setBackgroundColor(Default.Background)

-- [[   TEST   ]] --
	-- [[ CARTESIAN ]]
	-- f = Function.New()
	-- f.exp  = "(x-1)^2/2"
	-- f.mode = "cartesian"
	-- f.color = Colors.BrightYellow
	-- f:setDomain(-3, 3, 600)

	g = Function.New("math.sin(x) - 2")
	-- g.color = Colors.BrightRed
	-- g:setDomain(-math.pi, math.pi, 600)

	h = Function.New("math.sqrt( 9 - (x-1)^2 )")
	-- h.color = Colors.BrightPurple
	-- h:setDomain(-3, 3, 600)

	i = Function.New("(x^5 - x^3 + 2*x - 4) / (x^3 - 5*x)")
	-- i.color = Colors.BrightCyan
	-- i:setDomain(-3, 3, 600)

	-- j = Function.New("1/x")

	-- [[ POLAR ]]
	p = Function.New("math.sin(4*x)", "polar")
	p:setDomain(0, 2 * math.pi, 100)

	q = Function.New("math.sin(1.25*x)", "polar")
	q:setDomain(0, 2 * math.pi, 70)
-- [[ END TEST ]] --

	d = 4
end

function love.update(dt)
	if Editor.mode == "cartesian" then
		for i = 1, Function.ID do
			local f = Function.instances[i]
			if f ~= nil and f.mode == "cartesian" then
				f:computeGraph()
				f.graph = f.graph * Scale
				-- f:computeCOM() -- doesn't work here, but compiles...
			end
		end
	elseif Editor.mode == "polar" then
		for i = 1, Function.ID do
			local f = Function.instances[i]
			if f ~= nil and f.mode == "polar" then
				f:computeGraphPolar()
				f.graph = f.graph * Scale
				-- f:computeCOM() -- doesn't work here, but compiles...
			end
		end
	end

	if     love.keyboard.isDown("up")   then
		Origin.y = Origin.y + d
	elseif love.keyboard.isDown("down") then
		Origin.y = Origin.y - d
	end

	if     love.keyboard.isDown("left")  then
		Origin.x = Origin.x + d
	elseif love.keyboard.isDown("right") then
		Origin.x = Origin.x - d
	end

	if     love.keyboard.isDown("=") or love.keyboard.isDown("kp+") then
		Scale = Scale + d/2
	elseif love.keyboard.isDown("-") or love.keyboard.isDown("kp-") then
		Scale = Scale - d/2
	end

	if Scale < 1 then
		Scale = 1
	end
end

function love.draw()
	if Editor.mode == "cartesian" then
		draw_cartesian_axes({ x = Origin.x, y = Origin.y }, Viewport.width, Viewport.height)
	elseif Editor.mode == "polar" then
		draw_polar_axes({ x = Origin.x, y = Origin.y }, Viewport.width, Viewport.height)
	end

	for i = 1, Function.ID do
		local f = Function.instances[i]
		if f ~= nil and f.mode == Editor.mode then
			f:plot()
			f:computeCOM()
			f:drawCOM()
		end
	end

	love.graphics.setColor(Default.Color)
end

function love.keypressed(key)
	if key == "\\" and love.keyboard.isDown("rctrl") then
		debug.debug()
	end

	if key == "kp0" or key == "0" then
		Scale = Default.Scale
	end
end
