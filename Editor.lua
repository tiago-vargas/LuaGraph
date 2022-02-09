--- Manages graphes, functions, colors and such
local Editor =
{
	-- activeMode     = { "cartesian", "polar" },
	-- width,
	-- height,
	mode = "cartesian",
	font = love.graphics.getFont(),
	planeInstances = {},
	polarInstances = {},
	functions      = {},
	origin         = {},
	scale          = {},
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
	"BrightYellow",
	-- "BrightBlue",
	"BrightPurple",
	"BrightCyan",
}	-- "BrightWhite",
ColorIndex = 1

local Font = love.graphics.getFont()
local Offset = 5

--- Draws HUD
Editor.ShowHud = function ()
	love.graphics.print("Scale: " .. Scale, Offset, Viewport.height - Offset - Font:getHeight())
end

return Editor
