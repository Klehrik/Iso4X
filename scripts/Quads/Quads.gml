/// Quads

function draw_quad(x1, y1, x2, y2, x3, y3, x4, y4, col)
{
	//  1 -- 2
	//  |    |
	//  3 -- 4
	
	draw_triangle_colour(x1, y1, x2, y2, x3, y3, col, col, col, 0);
	draw_triangle_colour(x2, y2, x3, y3, x4, y4, col, col, col, 0);
}



function draw_stacked_quad(x1, y1, x2, y2, x3, y3, x4, y4, height, col)
{
	var points = [[x1, y1], [x2, y2], [x3, y3], [x4, y4]];
	
	// insertion sort
	for (var i = 1; i <= 3; i++)
	{
		for (var j = i; j > 0; j--)
		{
			// compare y value with previous element,
			// and swap if y value is smaller
			if (points[j][1] < points[j - 1][1])
			{
				var temp = points[j - 1];
				points[j - 1] = points[j];
				points[j] = temp;
			}
			
			// otherwise, end the loop for this element
			else break;
		}
	}
	
	var a = points[0];
	var b = points[1];
	var c = points[2];
	var d = points[3];
	
	draw_triangle_colour(a[0], a[1] - height, b[0], b[1], b[0], b[1] - height, col, col, col, 0);
	draw_triangle_colour(a[0], a[1] - height, c[0], c[1], c[0], c[1] - height, col, col, col, 0);
	draw_triangle_colour(a[0], a[1] - height, b[0], b[1], d[0], d[1], col, col, col, 0);
	draw_triangle_colour(a[0], a[1] - height, c[0], c[1], d[0], d[1], col, col, col, 0);
}