/// unit draw debug

// debug: draw grid
if (obj_Manager.Selected == id)
{
	for (var _y = 0; _y < Parent.GridHeight; _y++)
	{
		for (var _x = 0; _x < Parent.GridWidth; _x++)
		{
			var val = PathMap[# _x, _y];
			if (val == infinity) val = "-";
			else if (val == 100) val = "x";
			draw_text(_x * 10, _y * 10, val);
		}
	}
}