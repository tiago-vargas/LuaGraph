local Function = require("Function")
Editor   = require("Editor")
Colors   = require("Colors")

PI = math.pi

local Defaults =
{
	Mode       = "cartesian",
	Color      = Colors.Black,
	Background = Colors.BrightWhite,
	Scale      = 50,
}

local function TEST_FUNCTIONS()
	-- [[ CARTESIAN ]]
	f = Editor.NewFunction("f", "(x-1)^2 / 8")
	Editor.NewFunction("g", "sin(x) - 2")
	Editor.NewFunction("h", "sqrt( 9 - (x-1)^2 )")
	-- Editor.NewFunction("i", "(x^5 - x^3 + 2*x - 4) / (x^3 - 5*x)")
	Editor.NewFunction("j", "1/x")
	Editor.NewFunction("k", "sin(4*x) / x ^ 2 * 2")

	-- print(f.graph)


	-- [[ POLAR ]]
	p = Editor.NewFunction("p", "sin(4*x)", "polar")
	p.domain = Editor.NewDomain(0, 2 * PI, 100)
	p.isVisible = false

	q = Editor.NewFunction("q", "sin(1.25*x)", "polar")
	q.domain = Editor.NewDomain(0, 2 * PI, 70)
	q.isVisible = false

	r = Editor.NewFunction("r", "1", "polar")
	r.domain = Editor.NewDomain(0, 2*PI, 100)
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
	local is_ctrl_down = love.keyboard.isDown("rctrl", "lctrl")

	if key == "return" and is_ctrl_down then
		debug.debug()
	end

	if key == "m" and is_ctrl_down then
		Editor.ChangeMode()
	end

	if key == "kp0" or key == "0" then
		Editor.Scale = Defaults.Scale
	end
end
