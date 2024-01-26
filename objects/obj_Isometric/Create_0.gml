/// obj_Isometric : Init

Map = -1;

Grid = noone;
GridWidth = 8;
GridHeight = 8;
GridAngle = 45;
GridAngleTo = 45;
GridPers = 60; // Vertical perspective

TileSize = 16;
DiagSize = TileSize / 1.5; // The corners are actually root(2) distance away from the origin since they are diagonal

OriginX = CAM_W / 2;
OriginY = CAM_H / 2 + 8;

UnitGrid = noone; // Grid for position of all units



// Functions

function load_map(ID)
{
	Map = ID;
	var map = get_mapdata(ID);
	GridWidth = map.Width;
	GridHeight = map.Height;
}

function init_grid()
{
	if (Map != -1)
	{	
		Grid = ds_grid_create(GridWidth, GridHeight);
	
		var px_width = GridWidth * TileSize; // Get pixel dimensions of map
		var px_height = GridHeight * TileSize;
		var left = OriginX - (px_width / 2); // Get coordinates of top left corner of map
		var top = OriginY - (px_height / 2);
		var half_tilesize = TileSize / 2; // Set the tile coordinates with the origin in the center
	
		// Loop through grid and create a tile struct for each tile
		for (var _y = 0; _y < GridHeight; _y++)
		{
			for (var _x = 0; _x < GridWidth; _x++)
			{
				// Get tile data
				var height = get_mapdata(Map).Map[_y][_x];
				var ID = get_mapdata(Map).MapTiles[_y][_x];
				var type = get_tile_type(ID);
				var colours = get_tile_colours(ID);
				var structure = get_mapdata(Map).MapStructures[_y][_x];
				
				// Create tile object
				var tile = instance_create_depth(0, 0, 0, obj_GridTile);
				tile.Parent = id;
				tile.x = left + (_x * TileSize) + half_tilesize;
				tile.y = top + (_y * TileSize) + half_tilesize;
				tile.PosX = _x;
				tile.PosY = _y;
				tile.Height = height;
				tile.Type = type;
				tile.ColourBase = colours[1];
				tile.ColourInner = colours[2];
				tile.ColourBody = colours[3];
				
				// Add tile object to grid
				Grid[# _x, _y] = tile;
			
				// Create natural structures
				if (tile.Type >= 1)
				{
					var str = instance_create_depth(tile.x, tile.y, 0, obj_Structure);
					str.Parent = id;
					str.PosX = tile.PosX;
					str.PosY = tile.PosY;
					str.Height = tile.Height;
					str.image_index = tile.Type - 1;
				}
				
				// Create other structures
				if (structure != -1)
				{
					var str = instance_create_depth(tile.x, tile.y, 0, obj_Structure);
					str.Parent = id;
					str.PosX = tile.PosX;
					str.PosY = tile.PosY;
					str.Height = tile.Height;
					str.image_index = structure;
					
					str.HP = get_structure(structure).Health;
					str.MaxHP = get_structure(structure).Health;
				}
				
				
				
				// debug: make small man
				if (irandom_range(1, 100) <= 10)
				{
					var man = instance_create_depth(tile.x, tile.y, 0, obj_Unit);
					man.Parent = id;
					man.PosX = tile.PosX;
					man.PosY = tile.PosY;
					man.Height = tile.Height;
					man.init_pathmap();
					man.image_index = irandom_range(0, sprite_get_number(spr_UnitBlue));
					man.sprite_index = choose(spr_UnitBlue, spr_UnitRed);
					if (man.sprite_index == spr_UnitRed) man.Team = 2;
				}
			}
		}
	}
}



function init_unitgrid()
{
	UnitGrid = ds_grid_create(GridWidth, GridHeight);
	update_unitgrid();
}

function update_unitgrid()
{
	ds_grid_clear(UnitGrid, noone);
	with (obj_Unit) Parent.UnitGrid[# PosX, PosY] = id;
}

function get_from_unitgrid(tile)
{
	if (tile == noone) return noone;
	
	var unit = UnitGrid[# tile.PosX, tile.PosY];
	return unit;
}



function pathmap_show(unit)
{
	// Loop through grid and set tiles in move range to flashing
	for (var _y = 0; _y < GridHeight; _y++)
	{
		for (var _x = 0; _x < GridWidth; _x++)
		{
			var tile = Grid[# _x, _y];
			if (unit.PathMap[# _x, _y] <= unit.Move) tile.ColourHighlight = $ffad29;
			else if (unit.PathMap[# _x, _y] == 100) tile.ColourHighlight = $4d00ff;
		}
	}
}

function pathmap_attack_show(list)
{
	for (var i = 0; i < ds_list_size(list); i++)
	{
		var unit = list[| 0];
		Grid[# unit.PosX, unit.PosY].ColourHighlight = $4d00ff; // red
	}
}

function pathmap_hide()
{
	// Loop through grid and set all tiles to not flashing
	for (var _y = 0; _y < GridHeight; _y++)
	{
		for (var _x = 0; _x < GridWidth; _x++)
		{
			var tile = Grid[# _x, _y];
			tile.ColourHighlight = -1;
		}
	}
}



function get_tile_selected(_x, _y)
{
	var tile_selected = noone;
	
	// Loop through grid and get tile being selected
	var z_depth = -1; // to prevent selecting another tile behind the moused-over tile, select the tile that has the greatest RotPosY
	for (var _yy = 0; _yy < GridHeight; _yy++)
	{
		for (var _xx = 0; _xx < GridWidth; _xx++)
		{
			var tile = Grid[# _xx, _yy];
			if (tile.RotPosY > z_depth and tile.point_in_tile(_x, _y))
			{
				tile_selected = tile;
				z_depth = tile.RotPosY;
			}
		}
	}
	
	return tile_selected;
}

