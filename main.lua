local Function = require("Function")
Editor   = require("Editor")
Colors   = require("Colors")

Viewport = {}
Viewport.width, Viewport.height = love.graphics.getDimensions()

local Defaults =
{
	Mode       = "cartesian",
	Color      = Colors.Black,
	Background = Colors.BrightWhite,
	Origin     = { x = Viewport.width/2, y = Viewport.height/2 },
	Scale      = 50,
}

local function TEST_FUNCTIONS()
	-- [[ CARTESIAN ]]
	f = Editor.NewFunction("f", "(x-1)^2 / 8")
	Editor.NewFunction("g", "math.sin(x) - 2")
	Editor.NewFunction("h", "math.sqrt( 9 - (x-1)^2 )")
	-- Editor.NewFunction("i", "(x^5 - x^3 + 2*x - 4) / (x^3 - 5*x)")
	Editor.NewFunction("j", "1/x")
	Editor.NewFunction("k", "math.sin(4*x) / x ^ 2 * 2")

	-- print(f.graph)


	-- [[ POLAR ]]
	p = Editor.NewFunction("p", "math.sin(4*x)", "polar")
	p.domain = Editor.NewDomain(0, 2 * math.pi, 100)
	p.isVisible = false

	q = Editor.NewFunction("q", "math.sin(1.25*x)", "polar")
	q.domain = Editor.NewDomain(0, 2 * math.pi, 70)
	q.isVisible = false

	r = Editor.NewFunction("r", "1", "polar")
	r.domain = Editor.NewDomain(0, 2*math.pi, 100)
end

function love.load(args)
	Editor.Initialize(Defaults)

	TEST_FUNCTIONS()
end

function love.update(dt)
	Editor.ComputeAllFunctions()

	Editor.ManageOriginPanning()
	Editor.ManageZoom()
end

function love.draw()
	Editor.DrawHud()

	Editor.DrawAxes()
	Editor.DrawAllFunctions()
end

function love.keypressed(key)
	local is_ctrl_down = love.keyboard.isDown("rctrl") or love.keyboard.isDown("lctrl")

	if key == "\\" and is_ctrl_down then
		debug.debug()
	end

	if key == "m" and is_ctrl_down then
		if     Editor.Mode == "polar" then
			Editor.Mode = "cartesian"
		elseif Editor.Mode == "cartesian" then
			Editor.Mode = "polar"
		end
	end

	if key == "kp0" or key == "0" then
		Editor.Scale = Defaults.Scale
	end
end
