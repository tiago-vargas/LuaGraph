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
	Color      = Colors.Black,
	Background = Colors.BrightWhite,
	Scale      = { Lx = 50, Ly = 50 },
}

-- Maybe change this name...
function dist(P, Q)
	local dx = P.x - Q.x
	local dy = P.y - Q.y
	return math.sqrt( dx ^ 2 + dy ^ 2 )
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
	Scale  = Default.Scale
	love.graphics.setColor(Default.Color)
	love.graphics.setBackgroundColor(Default.Background)

-- [[   TEST   ]] --
	f = Function.New()
	f.exp = "(x-1)^2/2"
	-- f.color = Colors.BrightYellow
	-- f:setDomain(-3, 3, 600)

	g = Function.New("math.sin(x) - 2")
	-- g.color = Colors.BrightRed
	-- g:setDomain(-math.pi, math.pi, 600)

	h = Function.New("math.sqrt( 9 - (x-1)^2 )")
	-- h.color = Colors.BrightPurple
	h:setDomain(-3, 3, 600)

	i = Function.New("(x^5 - x^3 + 2*x - 4) / math.sin(x)")
	i.color = Colors.BrightCyan
	i:setDomain(-3, 3, 600)
-- [[ END TEST ]] --

	d = 4
end

function love.update(dt)
	for i = 1, Function.ID do
		local f = Function.instances[i]
		if f ~= nil then
			f:computeGraph(F)
			f.graph = f.graph * Scale
			-- f:computeCOM() -- doesn't work here, but compiles...
		end
	end

	-- for k, v in pairs(Function.instances) do
	-- 	if k ~= nil then
	-- 		v:computeGraph(F)
	-- 		v.graph = v.graph * Scale
	-- 		-- f:computeCOM() -- doesn't work here, but compiles...
	-- 	end
	-- end

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

	if     love.keyboard.isDown("d") then
		Scale.Lx = Scale.Lx + 2
	elseif love.keyboard.isDown("a") then
		Scale.Lx = Scale.Lx - 2
	end

	if     love.keyboard.isDown("w") then
		Scale.Ly = Scale.Ly + 2
	elseif love.keyboard.isDown("s") then
		Scale.Ly = Scale.Ly - 2
	end

	if     love.keyboard.isDown("=") or love.keyboard.isDown("kp+") then
		Scale.Lx = Scale.Lx + 2
		Scale.Ly = Scale.Ly + 2
	elseif love.keyboard.isDown("-") or love.keyboard.isDown("kp-") then
		Scale.Lx = Scale.Lx - 2
		Scale.Ly = Scale.Ly - 2
	end
end

function love.draw()
	drawaxis({ x = Origin.x, y = Origin.y }, Viewport.width, Viewport.height)

	for i = 1, Function.ID do
		local f = Function.instances[i]
		if f ~= nil then
			f:plot()
			f:computeCOM()
			f:drawCOM()
		end
	end

	-- for k, v in pairs(Function.instances) do
	-- 	if k ~= nil then
	-- 		v:plot()
	-- 		v:computeCOM()
	-- 		v:drawCOM()
	-- 	end
	-- end

	love.graphics.setColor(Default.Color)
end

function love.keypressed(key)
	if key == "\\"and love.keyboard.isDown("rctrl") then
		debug.debug()
	end

	if key == "kp0" or key == "0" then
		Scale = Default.Scale
	end
end
