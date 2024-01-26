/// obj_Unit : Init

image_alpha = 0;
image_speed = 0;

Parent = noone;

RotPosX = 0;
RotPosY = 0;

PosX = 0;
PosY = 0;
Height = 0;
HeightLerp = 0; // Used for drawing purposes when the unit moves

PathMap = -1;
MovePath = ds_list_create();
MovePixels = 0; // Amount of pixels left to move to the next tile
MovePrevTile = noone;
Moved = false;

PrevPosX = 0;
PrevPosY = 0;
PrevHeight = 0;

Team = 1;
HP = 3;
MaxHP = 3;
Defense = 0;
Attack = 2;
Counter = 1;
MinRange = 1;
MaxRange = 1;
Move = 3;

DrawAttackArrow = false;
DrawSlash = -1;



// Functions

function calculate_rot_pos()
{	
	// Get angle and distance from the origin of the map
	var angle = point_direction(Parent.OriginX, Parent.OriginY, x, y);
	var dist = point_distance(Parent.OriginX, Parent.OriginY, x, y);
	
	// Calculate rotated position
	angle += Parent.GridAngle;
	RotPosX = Parent.OriginX + dcos(angle) * dist;
	RotPosY = Parent.OriginY - dsin(angle) * dist * dsin(Parent.GridPers);
}

function pipeline_draw()
{
	var size = Parent.DiagSize;
	
	
	// Draw self
	var blend = c_white;
	if (Moved == true) blend = $606060;
	draw_sprite_ext(sprite_index, image_index, RotPosX, RotPosY + 4 - HeightLerp * size * dsin(90 - Parent.GridPers), image_xscale, 1, 0, blend, 1);
	
	
	// Draw slash (if attacked)
	if (DrawSlash >= 0)
	{
		if (global.Frame mod 5 == 0) DrawSlash += 1;
		draw_sprite(spr_Slash, DrawSlash, RotPosX, RotPosY + 6 - HeightLerp * size * dsin(90 - Parent.GridPers));
		if (DrawSlash >= 10) DrawSlash = -1; // End animation
	}
}

function draw_health()
{
	var size = Parent.DiagSize;
	
	
	// Draw health
	if (MaxHP > 0)
	{
		var _x = RotPosX - MaxHP;
		var _y = RotPosY + 6 - Height * size * dsin(90 - Parent.GridPers);
		
		for (var i = 0; i < MaxHP; i++)
		{
			var spr = 0;
			if (i < HP)
			{
				spr = 2;
				if (Team == 2) spr = 3;
			}
			draw_sprite(spr_HealthPips, spr, _x + i * 2, _y);
		}
	}
}

function draw_attack_arrow()
{
	if (DrawAttackArrow == true)
	{
		var size = Parent.DiagSize;
		
		
		// Draw arrow
		if (MaxHP > 0)
		{
			var _x = RotPosX;
			var _y = RotPosY - 10 - Height * size * dsin(90 - Parent.GridPers);
		
			draw_sprite(spr_Arrow, 0, _x, _y + sin(global.Frame / 15));
		}
	}
}



function init_pathmap()
{
	PathMap = ds_grid_create(Parent.GridWidth, Parent.GridHeight);
}

function update_pathmap(_x, _y)
{
	ds_grid_clear(PathMap, infinity); // Set distance of all tiles to infinity
	
	Open = ds_list_create();
	ds_list_add(Open, [_x, _y]);
	PathMap[# _x, _y] = 0;
	
	while (ds_list_size(Open) > 0)
	{
		var i = Open[| 0];
		
		// Check if current tile exceeds max movement
		if (PathMap[# i[0], i[1]] < Move)
		{
			// Check the tiles in the four directions of the current tile
			var _xx = [-1, 1, 0, 0];
			var _yy = [0, 0, -1, 1];
			for (var j = 0; j < 4; j += 1)
			{
				var nx = i[0] + _xx[j]; // neighbor tile
				var ny = i[1] + _yy[j];
				
				if (nx >= 0 and nx < Parent.GridWidth and ny >= 0 and ny < Parent.GridHeight) // Check if within grid
				{
					// Check if tile value is greater
					// and if the height difference is less than 2
					if (PathMap[# nx, ny] > PathMap[# i[0], i[1]]
					and abs(Parent.Grid[# nx, ny].Height - Parent.Grid[# i[0], i[1]].Height) < 2)
					{
						// Check if tile is occupied by enemy unit
						if (Parent.UnitGrid[# nx, ny] == noone or Parent.UnitGrid[# nx, ny].Team == Team)
						{
							PathMap[# nx, ny] = PathMap[# i[0], i[1]] + 1; // Set value of checked tile to (current tile + 1)
							ds_list_add(Open, [nx, ny]); // Add checked tile to the list
						}
					}
				}
			}
		}
		
		
		// Add attack tiles
		for (var k = MinRange; k <= MaxRange; k++) // Loop through ranges
		{
			for (var l = -k; l <= k; l++) // Loop through each row of the range
			{
				for (var m = -1; m <= 1; m += 2) // -1 and +1
				{
					var tx = i[0] + (k - abs(l)) * m; // abs(x) and abs(y) must add up to the range k
					var ty = i[1] + l;
										
					if (tx >= 0 and tx < Parent.GridWidth and ty >= 0 and ty < Parent.GridHeight) // Check if within grid
					{
						// Check if tile is unexplored
						// and if the height different is less than 2
						// * Ignore if range is more than 1
						if (PathMap[# tx, ty] == infinity
						and (abs(Parent.Grid[# tx, ty].Height - Parent.Grid[# i[0], i[1]].Height) < 2 or MinRange > 1 or MaxRange > 1))
						{
							PathMap[# tx, ty] = 100; // Set value to 100 (attack)
						}
					}
				}
			}
		}
		
		ds_list_delete(Open, 0);
	}
	
	ds_list_destroy(Open);
}



function calculate_movepath(tile)
{
	// Save current position
	PrevPosX = PosX;
	PrevPosY = PosY;
	PrevHeight = Height;
	
	
	// Update pathmap positioned to the tile-to-move-to
	var _x = PosX;
	var _y = PosY;
	update_pathmap(tile.PosX, tile.PosY);
	
	
	// Trek through pathmap to the tile-to-move-to
	ds_list_clear(MovePath);
	while (PathMap[# _x, _y] > 0)
	{
		var val = PathMap[# _x, _y];
		var height = Parent.Grid[# _x, _y].Height;
		
		if (PathMap[# _x - 1, _y] < val and abs(Parent.Grid[# _x - 1, _y].Height - height) < 2)
		{
			_x -= 1;
			ds_list_add(MovePath, "left");
		}
		else if (PathMap[# _x + 1, _y] < val and abs(Parent.Grid[# _x + 1, _y].Height - height) < 2)
		{
			_x += 1;
			ds_list_add(MovePath, "right");
		}
		else if (PathMap[# _x, _y - 1] < val and abs(Parent.Grid[# _x, _y - 1].Height - height) < 2)
		{
			_y -= 1;
			ds_list_add(MovePath, "up");
		}
		else if (PathMap[# _x, _y + 1] < val and abs(Parent.Grid[# _x, _y + 1].Height - height) < 2)
		{
			_y += 1;
			ds_list_add(MovePath, "down");
		}
	}
}

function get_targets_in_range()
{
	var targets = ds_list_create();
	
	// Add attack tiles
	for (var k = MinRange; k <= MaxRange; k++) // Loop through ranges
	{
		for (var l = -k; l <= k; l++) // Loop through each row of the range
		{
			for (var m = -1; m <= 1; m += 2) // -1 and +1
			{
				var tx = PosX + (k - abs(l)) * m; // abs(x) and abs(y) must add up to the range k
				var ty = PosY + l;
										
				if (tx >= 0 and tx < Parent.GridWidth and ty >= 0 and ty < Parent.GridHeight) // Check if within grid
				{
					// Check if the height different is less than 2
					// * Ignore if range is more than 1
					// and if Team is not the same
					if (abs(Parent.Grid[# tx, ty].Height - Parent.Grid[# PosX, PosY].Height) < 2 or MinRange > 1 or MaxRange > 1)
					{
						// Check if unit (if they exist) is NOT on the same team
						var unit = Parent.UnitGrid[# tx, ty];
						if (unit != noone)
						{
							if (Team != unit.Team) ds_list_add(targets, unit);
						}
					}
				}
			}
		}
	}
	
	return targets;
}

function refresh_position()
{
	// Get current tile and move self
	var current_tile = Parent.Grid[# PosX, PosY];
	
	x = current_tile.x;
	y = current_tile.y;
	Height = current_tile.Height;
	HeightLerp = Height;
}

