-- Drawing grid

-- FINISH THIS !!!
local function drawgrid(origin, scale, screen_width, screen_height)
	local d = screen_height / 10
	for i = 1, 10 do
		love.graphics.line(origin.x, origin.y)
	end
end
