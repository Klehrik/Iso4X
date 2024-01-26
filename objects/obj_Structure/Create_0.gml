/// obj_Structure : Init

image_alpha = 0;
image_speed = 0;

Parent = noone;

RotPosX = 0;
RotPosY = 0;

PosX = 0;
PosY = 0;
Height = 0;

HP = 0;
MaxHP = 0;



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
	draw_sprite_ext(sprite_index, image_index, RotPosX, RotPosY - Height * size * dsin(90 - Parent.GridPers), 1, 1, 0, c_white, 1);
}

function draw_health()
{
	var size = Parent.DiagSize;
	
	
	// Draw health
	if (MaxHP > 0)
	{
		var _x = RotPosX - MaxHP;
		var _y = RotPosY + 2 - Height * size * dsin(90 - Parent.GridPers);
		
		for (var i = 0; i < MaxHP; i++)
		{
			var spr = 0;
			if (i < HP) spr = 1;
			draw_sprite(spr_HealthPips, spr, _x + i * 2, _y);
		}
	}
}

