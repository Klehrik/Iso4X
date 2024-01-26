/// obj_GridTile : Init

Parent = noone;

x = 0;
y = 0;
RotPosX = 0; // Rotated position
RotPosY = 0;

PosX = 0;
PosY = 0;
Height = 0;

Type = 0;

ColourBase = c_gray;
ColourInner = c_white;
ColourBody = c_dkgray;

ColourHighlight = -1; // $ffad29;



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

function calculate_rot_pos_top()
{	
	// Get angle and distance from the origin of the map
	var angle = point_direction(Parent.OriginX, Parent.OriginY, x, y);
	var dist = point_distance(Parent.OriginX, Parent.OriginY, x, y);
	
	// Calculate rotated y position
	angle += Parent.GridAngle;
	return Parent.OriginY - dsin(angle) * dist * dsin(Parent.GridPers) - (Parent.TileSize / 2);
}

function pipeline_draw()
{
	var size = Parent.DiagSize;
	
	
	// Get angles of each corner of the tile
	var p1 = point_direction(RotPosX, RotPosY, RotPosX - size, RotPosY - size);
	var p2 = point_direction(RotPosX, RotPosY, RotPosX + size, RotPosY - size);
	var p3 = point_direction(RotPosX, RotPosY, RotPosX - size, RotPosY + size);
	var p4 = point_direction(RotPosX, RotPosY, RotPosX + size, RotPosY + size);
	
	
	// Draw rotated tile (body, stacked quad)
	if (Height > 0)
	{
		draw_stacked_quad(RotPosX + dcos(p1 + Parent.GridAngle) * size, RotPosY - dsin(p1 + Parent.GridAngle) * size * dsin(Parent.GridPers),
		RotPosX + dcos(p2 + Parent.GridAngle) * size, RotPosY - dsin(p2 + Parent.GridAngle) * size * dsin(Parent.GridPers),
		RotPosX + dcos(p3 + Parent.GridAngle) * size, RotPosY - dsin(p3 + Parent.GridAngle) * size * dsin(Parent.GridPers),
		RotPosX + dcos(p4 + Parent.GridAngle) * size, RotPosY - dsin(p4 + Parent.GridAngle) * size * dsin(Parent.GridPers),
		Height * size * dsin(90 - Parent.GridPers), ColourBody);
	}
	
	// Draw rotated tile (base)
	draw_quad(RotPosX + dcos(p1 + Parent.GridAngle) * size, RotPosY - dsin(p1 + Parent.GridAngle) * size * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	RotPosX + dcos(p2 + Parent.GridAngle) * size, RotPosY - dsin(p2 + Parent.GridAngle) * size * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	RotPosX + dcos(p3 + Parent.GridAngle) * size, RotPosY - dsin(p3 + Parent.GridAngle) * size * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	RotPosX + dcos(p4 + Parent.GridAngle) * size, RotPosY - dsin(p4 + Parent.GridAngle) * size * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	ColourBase);
	
	// Draw rotated tile (smaller center, lighter colour)
	var size2 = size * 0.8;
	draw_quad(RotPosX + dcos(p1 + Parent.GridAngle) * size2, RotPosY - dsin(p1 + Parent.GridAngle) * size2 * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	RotPosX + dcos(p2 + Parent.GridAngle) * size2, RotPosY - dsin(p2 + Parent.GridAngle) * size2 * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	RotPosX + dcos(p3 + Parent.GridAngle) * size2, RotPosY - dsin(p3 + Parent.GridAngle) * size2 * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	RotPosX + dcos(p4 + Parent.GridAngle) * size2, RotPosY - dsin(p4 + Parent.GridAngle) * size2 * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	ColourInner);
	
	
	// Draw rotated tile (highlight)
	if (ColourHighlight != -1)
	{
		var sine = 0.7 + sin(global.Frame / 20) * 0.1; // sine wave for flashing
		var size2 = size * sine;
		draw_set_alpha(sine + 0.2);
		draw_quad(RotPosX + dcos(p1 + Parent.GridAngle) * size2, RotPosY - dsin(p1 + Parent.GridAngle) * size2 * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
		RotPosX + dcos(p2 + Parent.GridAngle) * size2, RotPosY - dsin(p2 + Parent.GridAngle) * size2 * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
		RotPosX + dcos(p3 + Parent.GridAngle) * size2, RotPosY - dsin(p3 + Parent.GridAngle) * size2 * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
		RotPosX + dcos(p4 + Parent.GridAngle) * size2, RotPosY - dsin(p4 + Parent.GridAngle) * size2 * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
		ColourHighlight);
		draw_set_alpha(1);
	}
}

function draw_health()
{
	// Tiles do not have health silly :P
}



function point_in_tile(_x, _y)
{
	var size = Parent.DiagSize;
	
	
	// Get angles of each corner of the tile
	var p1 = point_direction(RotPosX, RotPosY, RotPosX - size, RotPosY - size);
	var p2 = point_direction(RotPosX, RotPosY, RotPosX + size, RotPosY - size);
	var p3 = point_direction(RotPosX, RotPosY, RotPosX - size, RotPosY + size);
	var p4 = point_direction(RotPosX, RotPosY, RotPosX + size, RotPosY + size);
		
		
	// Check if point collides with the tile
	var points = ds_list_create();
	ds_list_add(points,
	RotPosX + dcos(p1 + Parent.GridAngle) * size, RotPosY - dsin(p1 + Parent.GridAngle) * size * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	RotPosX + dcos(p2 + Parent.GridAngle) * size, RotPosY - dsin(p2 + Parent.GridAngle) * size * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	RotPosX + dcos(p4 + Parent.GridAngle) * size, RotPosY - dsin(p4 + Parent.GridAngle) * size * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers),
	RotPosX + dcos(p3 + Parent.GridAngle) * size, RotPosY - dsin(p3 + Parent.GridAngle) * size * dsin(Parent.GridPers) - (Height * size) * dsin(90 - Parent.GridPers));
	return point_in_polygon(_x, _y, points);
}

