/// obj_Manager : Draw

function rotate_view()
{
	var rot = 90;
	if (keyboard_check_pressed(ord("A"))) Map.GridAngleTo += rot;
	if (keyboard_check_pressed(ord("D"))) Map.GridAngleTo -= rot;

	Map.GridAngle += (Map.GridAngleTo - Map.GridAngle) / 14;
	if (abs(Map.GridAngleTo - Map.GridAngle) < 0.1) Map.GridAngle = Map.GridAngleTo;
}

function drawing_pipeline()
{
	// Initialize empty array (set to -1)
	var pipeline = [];
	for (var _y = 0; _y < CAM_H; _y++) pipeline[_y] = -1;
	
	
	// Add tiles
	with (obj_GridTile)
	{	
		calculate_rot_pos();
		
		// Get y position of the top point of tile
		var yy = calculate_rot_pos_top();
			
		// - Create new ds_list at pipeline position if one does not exist
		// - Add self to pipeline position ds_list
		if (pipeline[yy] == -1) pipeline[yy] = ds_list_create();
		ds_list_add(pipeline[yy], id);
	}
	
	// Add structures
	with (obj_Structure)
	{
		calculate_rot_pos();
			
		// - Create new ds_list at pipeline position if one does not exist
		// - Add self to pipeline position ds_list
		if (pipeline[RotPosY] == -1) pipeline[RotPosY] = ds_list_create();
		ds_list_add(pipeline[RotPosY], id);
	}
	
	// Add units
	with (obj_Unit)
	{
		calculate_rot_pos();
			
		// - Create new ds_list at pipeline position if one does not exist
		// - Add self to pipeline position ds_list
		if (pipeline[RotPosY] == -1) pipeline[RotPosY] = ds_list_create();
		ds_list_add(pipeline[RotPosY], id);
	}
	
	
	// Loop through pipeline and draw
	for (var _y = 0; _y < CAM_H; _y++)
	{
		if (pipeline[_y] != -1)
		{
			for (var i = 0; i < ds_list_size(pipeline[_y]); i++)
			{
				var obj = pipeline[_y][| i];
				obj.pipeline_draw();
				//obj.draw_health();
			}
			ds_list_destroy(pipeline[_y]);
		}
	}
	
	
	// Draw structure and unit health
	with (obj_Structure) draw_health();
	with (obj_Unit) draw_health();
	
	// Draw attack arrows above targets
	with (obj_Unit) draw_attack_arrow();
	
	// Draw options
	with (obj_Options) draw_options();
}

// -------------------- //

rotate_view();
drawing_pipeline();