local Colors = {}

Colors.White      = { 242, 242, 242 }
Colors.Black      = {  12,  12,  12 }
Colors.Red        = { 197,  15,  31 }
Colors.Green      = {  19, 161,  14 }
Colors.Yellow     = { 193, 156,   0 }
Colors.Blue       = {   0,  55, 218 }
Colors.Purple     = { 136,  23,  52 }
Colors.Cyan       = {  58, 150, 221 }
Colors.Grey       = { 118, 118, 118 }

Colors.BrightGrey   = { 204, 204, 204 }
Colors.BrightRed    = { 231,  72,  86 }
Colors.BrightGreen  = {  22, 198,  12 }
Colors.BrightBlue   = {  59, 120, 255 }
Colors.BrightPurple = { 180,   0, 158 }

-- Remember that `LOVE` uses colors from 0..1 instead of 0..255
for _, value in pairs(Colors) do
	for i = 1, 3 do
		value[i] = value[i] / 256
	end
end

return Colors
