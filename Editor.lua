local Function = require("Function")
local Colors   = require("Colors")

local Editor = {}

FunctionColors =
{
	Colors.Red,
	Colors.Green,
	Colors.Yellow,
	Colors.Blue,
	Colors.Purple,
	Colors.Cyan,
	Colors.Grey,
	Colors.BrightRed,
	Colors.BrightGreen,
	Colors.BrightBlue,
	Colors.BrightPurple,
}
local ColorIndex = 0

local function GetNextColor()
	ColorIndex  = ColorIndex + 1

	if ColorIndex > #FunctionColors then
		ColorIndex = 1
	end
	return FunctionColors[ColorIndex]
end

local Functions = {}
local Width, Height


-----------------------------------------------
--[[ Auxiliary Functions                   ]]--
-----------------------------------------------

--- Returns a table of points `(x, y)` as a sequence `{ x1, y1, x2, y2, ... }`
---
---@param graph table # Table of ordered pairs
---
local function unpack_graph(graph)
	local coordinates_sequence = {}

	for i = 1, #graph do
		local ordered_pair = graph[i]
		table.insert(coordinates_sequence, ordered_pair.x)
		table.insert(coordinates_sequence, ordered_pair.y)
	end

	return coordinates_sequence
end


-----------------------------------------------
--[[ Class Methods                         ]]--
-----------------------------------------------

Editor.Initialize = function (defaults)
	love.graphics.setColor(defaults.Color)
	love.graphics.setBackgroundColor(defaults.Background)
	Width, Height = love.graphics.getDimensions()

	Editor.Color      = defaults.Color
	Editor.Background = defaults.Background
	Editor.Mode       = defaults.Mode
	Editor.Scale      = defaults.Scale
	Editor.Origin     = { x = Width/2, y = Height/2 }
	Editor.Domain     = Editor.NewDomain(-50, 50, 2000)
end

Editor.NewDomain = function (a, b, subdivisions)
	local domain = {}
	local dx = (b - a) / subdivisions

	for x = a, b, dx do
		table.insert(domain, x)
	end

	return domain
end

--- Creates a new instance of `Function`
---
---@param pretty_exp string # Function expression without `"math."`
---@param mode?      string # `"cartesian"` | `"polar"`
---
Editor.NewFunction = function (name, pretty_exp, mode)
	local o = Function.New(pretty_exp, mode)
	Functions[name] = o

	o.name      = name
	o.isVisible = true
	o.domain    = Editor.Domain
	o.color     = GetNextColor()

	return o
end

Editor.RemoveFunction = function (name)
	Functions[name] = nil
end

Editor.ComputeAllGraphs = function ()
	for _, f in pairs(Functions) do
		if f.mode == Editor.Mode then
			f:computeGraph()
		end
	end
end

Editor.ComputeAllCOMs = function ()
	for _, f in pairs(Functions) do
		if f.mode == Editor.Mode then
			f:computeCOM()
		end
	end
end

local Font = love.graphics.getFont()
local Margin = 5

local function WriteNameInList(f, i)
	local text = string.format("%s(x) = %s", f.name, f.prettyExp)
	local name_y_pos = (Font:getHeight() + Margin) * i
	love.graphics.print(text, Margin, Margin + name_y_pos)
end

local function ListFunctionNames()
	local index = 0
	for _, f in pairs(Functions) do
		if f.isVisible then
			love.graphics.setColor(f.color)
		else
			love.graphics.setColor(Colors.BrightGrey)
		end

		if f.mode == Editor.Mode then
			index = index + 1
			WriteNameInList(f, index)
		end
	end

	love.graphics.setColor(Editor.Color)
end

Editor.DrawHud = function ()
	love.graphics.setColor(Editor.Color)

	love.graphics.print("-- Functions --", Margin, Margin)
	ListFunctionNames()

	local bottom = Height - Margin - Font:getHeight()
	local right  = Width  - Margin - 100
	love.graphics.print("Scale: " .. Editor.Scale, Margin, bottom)
	love.graphics.print("Mode: "  .. Editor.Mode,  right,  bottom)
end

Editor.DrawAxes = function ()
	local O = Editor.Origin
	love.graphics.line(0, O.y,  Width,  O.y) -- Ox
	love.graphics.line(O.x, 0,  O.x, Height) -- Oy
end

local function Plot(f)
	love.graphics.setColor(f.color)

	local transformed_graph = (f.graph * Editor.Scale) + Editor.Origin
	love.graphics.line(unpack_graph(transformed_graph))
end

Editor.PlotAllGraphs = function ()
	for _, f in pairs(Functions) do
		if f.mode == Editor.Mode and f.isVisible then
			Plot(f)
		end
	end
end

local point_radius = 4

local function PlotCOM(f)
	love.graphics.setColor(f.color)

	local com_x_pos = (f.com.x *  Editor.Scale) + Editor.Origin.x
	local com_y_pos = (f.com.y * -Editor.Scale) + Editor.Origin.y
	love.graphics.circle("fill", com_x_pos, com_y_pos, point_radius)

	local text_x_pos = com_x_pos + Margin
	local text_y_pos = com_y_pos - Margin - Font:getHeight()
	local text = string.format("CoM (%.2f, %.2f)", f.com.x, f.com.y)
	love.graphics.print(text, text_x_pos, text_y_pos)
end

Editor.PlotAllCOMs = function ()
	for _, f in pairs(Functions) do
		if f.mode == Editor.Mode and f.isVisible then
			PlotCOM(f)
		end
	end
end

local key = love.keyboard

Editor.ManageOriginPanning = function ()
	local delta = 4

	if     key.isDown("up")   then
		Editor.Origin.y = Editor.Origin.y + delta
	elseif key.isDown("down") then
		Editor.Origin.y = Editor.Origin.y - delta
	end

	if     key.isDown("left")  then
		Editor.Origin.x = Editor.Origin.x + delta
	elseif key.isDown("right") then
		Editor.Origin.x = Editor.Origin.x - delta
	end
end

Editor.ManageZoom = function ()
	local delta = 2

	local zoom_in_pressed  = key.isDown("=", "kp+")
	local zoom_out_pressed = key.isDown("-", "kp-")

	if     zoom_in_pressed  then
		Editor.Scale = Editor.Scale + delta
	elseif zoom_out_pressed then
		Editor.Scale = Editor.Scale - delta
	end

	if Editor.Scale < 1 then
		Editor.Scale = 1
	end
end

Editor.ChangeMode = function ()
	if     Editor.Mode == "polar" then
		Editor.Mode = "cartesian"
	elseif Editor.Mode == "cartesian" then
		Editor.Mode = "polar"
	end
end

return Editor
