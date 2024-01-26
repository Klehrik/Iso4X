/// obj_Options : Init

Parent = noone;

Options = ds_list_create();
Follow = noone;
FollowOffsetY = 0;

Hide = false;



// Functions

function get_max_length()
{
	// Get longest option in terms of text length
	max_length = 0;
	for (var i = 0; i < ds_list_size(Options); i++)
	{
		if (string_length(Options[| i]) > max_length) max_length = string_length(Options[| i]);
	}
	return max_length;
}

function draw_options()
{
	if (Hide == false)
	{
		get_max_length();
	
		// Get origin point
		var _x = x;
		var _y = y;
		if (Follow != noone)
		{
			var _x = Follow.RotPosX;
			var _y = Follow.RotPosY + FollowOffsetY - Follow.Height * Parent.Map.DiagSize * dsin(90 - Parent.Map.GridPers);
		}
	
		// Draw option boxes
		var max_length = get_max_length();
		var x_off = max_length * 2 + 2; // x offset to center boxes
		draw_set_halign(fa_center);
		for (var i = 0; i < ds_list_size(Options); i++)
		{
			draw_rectangle_colour(_x - x_off, _y + (i * 10), _x + x_off, _y + 8 + (i * 10), c_black, c_black, c_black, c_black, 0);
			draw_text(_x + 1, _y + 2 + (i * 10), Options[| i]);
		}
		draw_set_halign(fa_left);
	}
}

function get_selected_option(_x, _y)
{
	if (Hide == false)
	{
		get_max_length();
	
		// Get origin point
		var _xx = x;
		var _yy = y;
		if (Follow != noone)
		{
			var _xx = Follow.RotPosX;
			var _yy = Follow.RotPosY + FollowOffsetY - Follow.Height * Parent.Map.DiagSize * dsin(90 - Parent.Map.GridPers);
		}
	
		// Loop through options and check if the point collides with them
		var max_length = get_max_length();
		var x_off = max_length * 2 + 2; // x offset to center boxes
		var option = -1;
		for (var i = 0; i < ds_list_size(Options); i++)
		{
			if point_in_rectangle(_x, _y, _xx - x_off, _yy + (i * 10), _xx + x_off + 1, _yy + 9 + (i * 10)) option = Options[| i];
		}
		return option;
	}
}

