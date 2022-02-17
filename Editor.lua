local Function = require("Function")
local Colors   = require("Colors")

local Editor = {}

-- MELHORAR
FunctionColors =
{
	"Red",
	"Green",
	"Yellow",
	"Blue",
	"Purple",
	"Cyan",
	"Grey",

	"BrightRed",
	"BrightGreen",
	"BrightBlue",
	"BrightPurple",
}
local ColorIndex = 1

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
	Editor.Domain     = Editor.NewDomain(-50, 50, 1000)
end

local Font = love.graphics.getFont()
local Margin = 5

-- MELHORAR
local function DrawName(f, i)
	local text = string.format("%s(x) = %s", f.name, f.pretty_exp)
	local name_y_pos = (Font:getHeight() + Margin) * (i - 1)
	love.graphics.print(text, Margin, Margin + name_y_pos)
end

-- EXPLICAR
local function DrawNameList()
	local index = 0
	for _, f in pairs(Functions) do
		if f.isVisible then
			love.graphics.setColor(f.color)
		else
			love.graphics.setColor(Colors.BrightGrey)
		end

		if f.mode == Editor.Mode then
			index = index + 1
			DrawName(f, index)
		end
	end
end

Editor.DrawHud = function ()
	DrawNameList()

	love.graphics.setColor(Editor.Color)

	local bottom = Height - Margin - Font:getHeight()
	local left   = Margin
	local right  = Width  - Margin - 100
	love.graphics.print("Scale: " .. Editor.Scale, left, bottom)
	love.graphics.print("Mode: "  .. Editor.Mode, right, bottom)
end

Editor.DrawAxes = function ()
	local O = Editor.Origin
	love.graphics.line(0, O.y,  Width,  O.y) -- Ox
	love.graphics.line(O.x, 0,  O.x, Height) -- Oy
end

Editor.NewDomain = function (a, b, subdivisions)
	local domain = {}
	local dx = (b - a) / subdivisions

	for x = a, b, dx do
		table.insert(domain, x)
	end

	return domain
end

-- MELHORAR
--- Creates a new instance of `Function`
---
---@param pretty_exp string # Function expression without `"math."`
---@param mode?      string # `"cartesian"` | `"polar"`
---
Editor.NewFunction = function (name, pretty_exp, mode)
	local o = Function.New(pretty_exp, mode)
	table.insert(Functions, o)

	o.name      = name
	o.isVisible = true
	o.domain    = Editor.Domain
	o.color     = Colors[FunctionColors[ColorIndex]]
	ColorIndex  = ColorIndex + 1

	return o
end

-- ESTUDAR
Editor.RemoveFunction = function (name)
	local i = 0

	repeat
		i = i + 1
	until Functions[i].name == name

	if i <= #Functions then
		table.remove(Functions, i)
	end
end

local dot_radius = 4
local offset_center = 13

Editor.ComputeAllGraphs = function ()
	for i = 1, #Functions do
		local f = Functions[i]
		if f.mode == Editor.Mode then
			f:computeGraph()
		end
	end
end

Editor.ComputeAllCOMs = function ()
	for i = 1, #Functions do
		local f = Functions[i]
		if f.mode == Editor.Mode then
			f:computeCOM()
		end
	end
end

-- MELHORAR
local function Plot(f)
	love.graphics.setColor(f.color)
	love.graphics.line(unpack_graph(f.graph * Editor.Scale + Editor.Origin))
end

Editor.PlotAllGraphs = function ()
	for i = 1, #Functions do
		local f = Functions[i]
		if f.mode == Editor.Mode and f.isVisible then
			Plot(f)
		end
	end
end

-- MELHORAR
local function PlotCOM(f)
	love.graphics.setColor(f.color)

	local x_pos = f.com.x * Editor.Scale + Editor.Origin.x
	local y_pos = f.com.y * Editor.Scale + Editor.Origin.y
	love.graphics.circle("fill", x_pos, y_pos, dot_radius)

	x_pos = x_pos - offset_center
	y_pos = y_pos - Font:getHeight() - Margin

	local text = string.format("CoM (%.2f, %.2f)", f.com.x, -f.com.y)
	love.graphics.print(text, x_pos, y_pos)
end

Editor.PlotAllCOMs = function ()
	for i = 1, #Functions do
		local f = Functions[i]
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
