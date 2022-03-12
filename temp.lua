local T = {}

local Colors = require "Colors"

function CAPA()
	Editor.Scale = 200
	Editor.Mode = "polar"

	local p0 = Editor.NewFunction("p0", "1", "polar")
	local p1 = Editor.NewFunction("p1", "sin(4*x)", "polar")
	local p2 = Editor.NewFunction("p2", "sin(4*x) * 6/7", "polar")
	local p3 = Editor.NewFunction("p3", "sin(4*x) / 2", "polar")
	local p4 = Editor.NewFunction("p4", "sin(4*x) * 3/21", "polar")

	p0.color = Colors.BrightGrey
	p1.color = Colors.Cyan
	p2.color = Colors.Grey
	p3.color = Colors.BrightRed
	p4.color = Colors.Red

	local domain = Editor.NewDomain(0, 2*PI, 400)

	p0.domain = domain
	p1.domain = domain
	p2.domain = domain
	p3.domain = domain
	p4.domain = domain
end

function NADA_DE_CAPA()
	Editor.RemoveFunction("p0")
	Editor.RemoveFunction("p1")
	Editor.RemoveFunction("p2")
	Editor.RemoveFunction("p3")
	Editor.RemoveFunction("p4")
end

return T
