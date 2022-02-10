--- Manages graphes, functions, colors and such
local Editor =
{
	-- width,
	-- height,
	mode = "cartesian",
	-- planeInstances = {},
	-- polarInstances = {},
	instances = {},
	functions = {},
	origin    = {},
	scale     = {},
}

Cor =
{
	-- "Black",
	"Red",
	"Green",
	"Yellow",
	-- "Blue",
	"Purple",
	"Cyan",
	-- "White",

	-- "BrightBlack",
	"BrightRed",
	"BrightGreen",
	-- "BrightYellow",
	-- "BrightBlue",
	"BrightPurple",
	"BrightCyan",
}	-- "BrightWhite",
ColorIndex = 1


-----------------------------------------------
--[[ Auxiliary functions                   ]]--
-----------------------------------------------

--- Unpacks table of points `(x, y)` into a sequence { x1, y1, x2, y2, ... }
---
--- Returns this sequence
---
---@param graph table
---
---@return table coordinates_sequence
---
local function unpack_graph(graph)
	local coordinates = {}

	for i = 1, #graph do
		table.insert(coordinates, graph[i].x)
		table.insert(coordinates, graph[i].y)
	end

	return coordinates
end


-----------------------------------------------
--[[ Class Methods                         ]]--
-----------------------------------------------

local Font = love.graphics.getFont()
local Offset = 5

--- Draws HUD
Editor.ShowHud = function ()
	love.graphics.print("Scale: " .. Scale, Offset, Viewport.height - Offset - Font:getHeight())

	for i = 1, #Editor.instances do
		local f = Editor.instances[i]
		love.graphics.setColor(f.color)
		-- love.graphics.print("#"..i..": " .. f.exp, Offset, Offset + Font:getHeight() * (i-1))
		love.graphics.print(f.name.."(x) = " .. f.exp, Offset, Offset + Font:getHeight() * (i-1))
	end
end

--- Creates a new instance of `Function`
---
---@param name   string # Name of the function
---@param exp    string # Function expression
---@param mode?  string # `"cartesian"` | `"polar"`
---@param color? table  # Graph color
---
Editor.NewFunction = function (name, exp, mode, color)
	local o = Function.New(exp, mode, color)
	o.name = name

	table.insert(Editor.instances, o)
	-- o.id = #Editor.instances

	return o
end

--- Deletes a function
---
---@param name string # Function name
---
Editor.RemoveFunction = function (name)
	local i = 1
	while i <= #Editor.instances and Editor.instances[i].name ~= name do
		i = i + 1
	end

	if i <= #Editor.instances then
		table.remove(Editor.instances, i)
	end
end

--- Draws the graph based on the function's mode
---
---@param f table # `Function`
---
Editor.Plot = function (f)
	love.graphics.setColor(f.color)
	love.graphics.line(unpack_graph(f.graph + Origin))
end

local dot_radius = 4
local offset_center = 13

--- Draws the center of mass of a graph
---
---@param f table # `Function`
---
Editor.DrawCOM = function (f)
	-- love.graphics.setColor(1, 1, 1, 0.75)
	-- love.graphics.rectangle("fill", f.com.x - offset_center, f.com.y - Font:getHeight() - Offset, 20, Font:getHeight())

	love.graphics.setColor(f.color)
	love.graphics.circle("fill", f.com.x, f.com.y, dot_radius)

	love.graphics.print("CoM", f.com.x - offset_center, f.com.y - Font:getHeight() - Offset)
end

return Editor
