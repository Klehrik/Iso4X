/// obj_Unit : Step

function movement_path()
{
	if (MovePixels > 0)
	{
		MovePixels -= 1; // 16 -> 0
		
		var current_tile = Parent.Grid[# PosX, PosY];
		var inverse_mp = Parent.TileSize - MovePixels;
		
		// Lerp between previous tile to tile-to-move-to
		var percent = inverse_mp / Parent.TileSize;
		x = lerp(MovePrevTile.x, current_tile.x, percent);
		y = lerp(MovePrevTile.y, current_tile.y, percent);
		
		// Height curve
		if (MovePrevTile.Height <= current_tile.Height) Height = current_tile.Height; // Moving upwards or same height (not downwards)
		//    * To future me, I already worked out the alignments here
		//    * Basically when moving downwards, if you set Height to next tile immediately then the pipeline_draw will draw from there
		//    * and it will be off downwards a few pixels
		HeightLerp = Height + dsin(lerp(0, 210, inverse_mp / Parent.TileSize));
		
		// Flip image
		if (RotPosX < current_tile.RotPosX) image_xscale = 1;
		else image_xscale = -1;
		
		
		// End of movement
		if (MovePixels <= 0)
		{
			refresh_position();
			
			// End of movement queue
			if (ds_list_size(MovePath) <= 0)
			{
				image_xscale = 1;
				Parent.update_unitgrid();
			}
		}
	}
	
	
	
	// Get next move direction
	else if (ds_list_size(MovePath) > 0)
	{
		MovePixels = Parent.TileSize;
		var dir = MovePath[| 0];
		
		MovePrevTile = Parent.Grid[# PosX, PosY];
		if (dir == "left") PosX -= 1;
		else if (dir == "right") PosX += 1;
		else if (dir == "up") PosY -= 1;
		else if (dir == "down") PosY += 1;
		
		ds_list_delete(MovePath, 0);
	}
	
	else HeightLerp = Height;
}

// -------------------- //

movement_path();