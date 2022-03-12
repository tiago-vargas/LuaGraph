Editor = require("Editor")
Colors = require("Colors")

require("temp")

PI = math.pi

local Defaults =
{
	Mode       = "cartesian",
	Color      = Colors.Black,
	Background = Colors.White,
	Scale      = 50,
}

function love.load()
	Editor.Initialize(Defaults)
end

function love.update()
	Editor.ComputeAllGraphs()
	Editor.ComputeAllCOMs()

	Editor.ManageOriginPanning()
	Editor.ManageZoom()
end

function love.draw()
	Editor.DrawHud()
	Editor.DrawAxes()

	Editor.PlotAllGraphs()
	Editor.PlotAllCOMs()
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
