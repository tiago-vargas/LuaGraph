Function = require("Function")
Colors   = require("Colors")

Origin = {}
Scale  = {}
Mode   = "polar"

Cor = {
	-- "Black",
	"Red",
	"Green",
	"Yellow",
	-- "Blue",
	"Purple",
	"Cyan",
	-- "White",

	"BrightRed",
	"BrightGreen",
	"BrightYellow",
	-- "BrightBlue",
	"BrightPurple",
	"BrightCyan",
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

--[[ Substitutes `x` for its value in an expression string ]]
function Parser(x, funcexp)
	local exp = funcexp:gsub("x", x)
	-- exp = exp:gsub("sin",  "math.sin")
	-- exp = exp:gsub("cos",  "math.cos")
	-- exp = exp:gsub("tan",  "math.tan")
	-- exp = exp:gsub("sqrt", "math.sqrt")
	-- exp = exp:gsub("pi",   "math.pi")
	return load("return " .. exp)()
end

--[[ draws 0x and 0y axes centered in `origin` ]]
local function drawaxesxy(origin, screen_width, screen_height)
	love.graphics.line(0, origin.y, screen_width,  origin.y) -- Ox
	love.graphics.line(origin.x, 0, origin.x, screen_height) -- Oy
end

--[[ draws 0x polar axis centered in `origin` ]]
-- local function drawaxispolar(origin, screen_width, screen_height)
-- 	love.graphics.line(0, origin.y, screen_width,  origin.y) -- Ox
-- 	love.graphics.line(origin.x, 0, origin.x, screen_height) -- Oy
-- end

function love.load(args)
	Viewport.width, Viewport.height = love.graphics.getDimensions()
	Origin = { x = Viewport.width/2, y = Viewport.height/2 }
	Scale  = Default.Scale
	love.graphics.setColor(Default.Color)
	love.graphics.setBackgroundColor(Default.Background)

-- [[   TEST   ]] --
	-- [[ XY ]]
	f = Function.New()
	f.exp = "(x-1)^2/2"
	f.mode = "plane"
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
	if Mode == "plane" then
		for i = 1, Function.ID do
			local f = Function.instances[i]
			if f ~= nil and f.mode == "plane" then
				f:computeGraph(Parser)
				f.graph = f.graph * Scale
				-- f:computeCOM() -- doesn't work here, but compiles...
			end
		end
	elseif Mode == "polar" then
		for i = 1, Function.ID do
			local f = Function.instances[i]
			if f ~= nil and f.mode == "polar" then
				f:computeGraphPolar(Parser)
				f.graph = f.graph * Scale
				-- f:computeCOM() -- doesn't work here, but compiles...
			end
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
	drawaxesxy({ x = Origin.x, y = Origin.y }, Viewport.width, Viewport.height)

	-- drawaxispolar({ x = Origin.x, y = Origin.y }, Viewport.width, Viewport.height)

	for i = 1, Function.ID do
		local f = Function.instances[i]
		if f ~= nil and f.mode == Mode then
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
