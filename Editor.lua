local Function = require("Function")
local Colors   = require("Colors")

--- Manages graphes, functions, colors and such
local Editor =
{
	-- width,
	-- height,
	Mode = "cartesian",
	Origin    = {},
	Scale     = 0
}

FunctionColors =
{
	"Red",
	"Green",
	"Yellow",
	"Blue",
	"Purple",
	"Cyan",

	"BrightBlack",
	"BrightRed",
	"BrightGreen",
	"BrightBlue",
	"BrightPurple",
}
local ColorIndex = 1

local Functions = {}


-----------------------------------------------
--[[ Auxiliary Functions                   ]]--
-----------------------------------------------

--- Unpacks a table of points `(x, y)` into a sequence `{ x1, y1, x2, y2, ... }`
---
--- Returns this sequence
---
---@param graph table # Table of ordered pairs
---
---@return table coordinates_sequence
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

	Editor.color      = defaults.Color
	Editor.background = defaults.Background
	Editor.Scale      = defaults.Scale
	Editor.Origin     = defaults.Origin
	Editor.width      = Viewport.width
	Editor.height     = Viewport.height
end

local Font = love.graphics.getFont()
local Margin = 5

Editor.DrawHud = function ()
	for i = 1, #Functions do
		local f = Functions[i]
		if f.isVisible then
			love.graphics.setColor(f.color)
		else
			love.graphics.setColor(Colors.White)
		end

		love.graphics.print(f.name.."(x) = " .. f.exp, Margin, Margin + (Margin + Font:getHeight())*(i - 1))
	end

	love.graphics.setColor(Editor.color)

	local bottom = Editor.height - Margin - Font:getHeight()
	local left   = Margin
	local right  = Editor.width  - Margin - 100
	love.graphics.print("Scale: " .. Editor.Scale, left, bottom)
	love.graphics.print("Mode: "  .. Editor.Mode, right, bottom)
end

--- Creates a domain with ends on `a` and `b`, with `n` subdivisions,
--- e.g. `n = 2` means just the two endpoints
---
--- Returns the domain
---
---@param a number
---@param b number
---@param n number
---
---@return table domain
---
Editor.NewDomain = function (a, b, n)
	local domain = {}
	local dx = (b - a) / n

	for x = a, b, dx do
		table.insert(domain, x)
	end

	return domain
end

--- Creates a new instance of `Function`
---
---@param name   string # Name of the function
---@param exp    string # Function expression
---@param mode?  string # `"cartesian"` | `"polar"`
---@param color? table  # Graph color
---
Editor.NewFunction = function (name, exp, mode, color)
	local o = Function.New(exp, mode)
	table.insert(Functions, o)

	o.name     = name
	o.color    = color or Colors[FunctionColors[ColorIndex]]
	ColorIndex = ColorIndex + 1

	o.domain = Editor.NewDomain(-50, 50, 1000)
	o:computeGraph()

	return o
end

--- Deletes a function
---
---@param name string # Function name
---
Editor.RemoveFunction = function (name)
	local i = 1
	while i <= #Functions and Functions[i].name ~= name do
		i = i + 1
	end

	if i <= #Functions then
		table.remove(Functions, i)
	end
end

local dot_radius = 4
local offset_center = 13

--- Draws the center of mass of a graph
---
---@param f table # `Function`
---
Editor.DrawCOM = function (f)
	love.graphics.setColor(f.color)
	love.graphics.circle("fill", f.com.x, f.com.y, dot_radius)

	local x_pos = f.com.x - offset_center
	local y_pos = f.com.y - Font:getHeight() - Margin
	-- love.graphics.print("CoM("..f.com.x - Origin.x..", "..f.com.y - Origin.y..")",
	--                     x_pos, y_pos)
	love.graphics.print("CoM", x_pos, y_pos)
end

local function ComputeFunction(f)
	if Editor.Mode == "cartesian" then
		f:computeCartesianGraph()
	elseif Editor.Mode == "polar" then
		f:computePolarGraph()
	end

	f.graph = f.graph * Editor.Scale
	-- f:computeCOM() -- doesn't work here, but compiles...
end

Editor.ComputeAllFunctions = function ()
	for i = 1, #Functions do
		local f = Functions[i]
		if f.mode == Editor.Mode then
			ComputeFunction(f)
		end
	end
end

--- Draws the graph relative to the origin
---
--- The system in which the graph is drawn is based on the function's mode
---
---@param f table # `Function`
---
Editor.Plot = function (f)
	love.graphics.setColor(f.color)
	love.graphics.line(unpack_graph(f.graph + Editor.Origin))
end


local function DrawFunction(f)
	Editor.Plot(f)
	f:computeCOM() -- should not be here...
	Editor.DrawCOM(f)
end

Editor.DrawAllFunctions = function ()
	for i = 1, #Functions do
		local f = Functions[i]
		if f.mode == Editor.Mode and f.isVisible then
			DrawFunction(f)
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

Editor.DrawCartesianSubgrid = function ()
end

Editor.DrawPolarSubgrid = function ()
end

--- Draws Ox and Oy axes centered in the Origin
Editor.DrawAxes = function ()
	local O = Editor.Origin
	love.graphics.line(0, O.y,  Editor.width,  O.y) -- Ox
	love.graphics.line(O.x, 0,  O.x, Editor.height) -- Oy

	if Editor.Mode == "cartesian" then
		Editor.DrawCartesianSubgrid()
	elseif Editor.Mode == "polar" then
		Editor.DrawPolarSubgrid()
	end
end

return Editor
