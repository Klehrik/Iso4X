/// obj_Manager : Step

function state_machine()
{
	switch (SelectedState)
	{
		// Select a unit
		case 0:
			if (mouse_check_button_pressed(mb_left))
			{
				Selected = noone;
				SelectedState = 0;
				Map.pathmap_hide();
				
				var tile = Map.get_tile_selected(mouse_x, mouse_y);
				var unit = Map.get_from_unitgrid(tile);
				
				if (unit != noone)
				{
					if (unit.Moved == false)
					{
						Selected = unit;
						SelectedState = 1;
						Selected.update_pathmap(Selected.PosX, Selected.PosY); // Update pathfind map
						Map.pathmap_show(Selected);
					}
				}
			}
			break;
		
		
		
		// Move selected unit
		case 1:
			if (mouse_check_button_pressed(mb_left))
			{
				var tile = Map.get_tile_selected(mouse_x, mouse_y);
				
				// Invalid tile (null, out of range, or occupied)
				if (tile == noone
				or Selected.PathMap[# tile.PosX, tile.PosY] > Selected.Move
				or (Map.UnitGrid[# tile.PosX, tile.PosY] != noone and Map.UnitGrid[# tile.PosX, tile.PosY] != Selected))
				{
					Selected = noone;
					SelectedState = 0;
					Map.pathmap_hide();
				}
				
				// Move to tile
				else
				{
					Selected.calculate_movepath(tile);
					SelectedState = 1.1;
					Map.pathmap_hide();
				}
			}
			break;
			
			
		
		// Unit is moving... waiting for finish
		case 1.1:
			if (Selected.MovePixels <= 0 and ds_list_size(Selected.MovePath) <= 0)
			{
				SelectedState = 2;
				
				var _x = Selected.RotPosX;
				var _y = Selected.RotPosY + 6 - Selected.Height * Map.DiagSize * dsin(90 - Map.GridPers);
				Options = instance_create_depth(_x, _y, 0, obj_Options);
				Options.Parent = id;
				Options.Follow = Selected;
				Options.FollowOffsetY = 6;
				
				// Check if any enemy units are in attack range
				// and make a list of them
				if (ds_exists(SelectedTargets, ds_type_list)) ds_list_destroy(SelectedTargets);
				SelectedTargets = Selected.get_targets_in_range();
				if (ds_list_size(SelectedTargets) > 0) ds_list_add(Options.Options, "Attack");
				
				ds_list_add(Options.Options, "Wait");
			}
			break;
		
		
		
		// Unit options
		case 2:
			if (mouse_check_button_pressed(mb_left))
			{
				var option = Options.get_selected_option(mouse_x, mouse_y);
				
				if (option != -1)
				{
					// Check which option was selected
					switch (option)
					{
						case "Attack":
							SelectedState = 3;
							Map.pathmap_attack_show(SelectedTargets);
							Options.Hide = true;
							
							// Show attack arrows
							for (var i = 0; i < ds_list_size(SelectedTargets); i++) SelectedTargets[| i].DrawAttackArrow = true;
							break;
							
							
							
						case "Wait":
							Selected.Moved = true;
							Selected = noone;
							SelectedState = 0;
							
							instance_destroy(Options);
							break;
					}
				}
				
				// Roll back unit position to previous position
				else
				{
					Selected.PosX = Selected.PrevPosX;
					Selected.PosY = Selected.PrevPosY;
					Selected.Height = Selected.PrevHeight;
					Selected.refresh_position();
				
					SelectedState = 1;
					Selected.update_pathmap(Selected.PosX, Selected.PosY); // Update pathfind map
					Map.pathmap_show(Selected);
				
					Map.update_unitgrid();
				
					instance_destroy(Options);
				}
			}
			break;
			
		
		
		// Select attack target
		case 3:
			if (mouse_check_button_pressed(mb_left))
			{
				var tile = Map.get_tile_selected(mouse_x, mouse_y);
				var unit = Map.get_from_unitgrid(tile);
				
				// Check if enemy target was selected
				if (unit != noone and ds_list_find_index(SelectedTargets, unit) != -1)
				{
					Target = unit;
					
					// Deal damage
					Target.DrawSlash = 0;
					unit.HP -= max(Selected.Attack - unit.Defense, 0);
					
					SelectedState = 3.1;
					Map.pathmap_hide();
					instance_destroy(Options);
				}
				
				// Back
				else
				{
					SelectedState = 2;
					Map.pathmap_hide();
					Options.Hide = false;
				}
				
				
				
				// Hide attack arrows
				with (obj_Unit) { DrawAttackArrow = false; }
			}
			break;
			
			
		
		// Target slash anim (attack)
		case 3.1:
			if (Target.DrawSlash <= -1)
			{
				// Check if Target is still alive
				// If so, counterattack (if applicable)
				if (Target.HP > 0)
				{
					var targets = Target.get_targets_in_range();
					if (ds_list_find_index(targets, Selected) != -1)
					{
						// Deal damage
						Selected.DrawSlash = 0;
						Selected.HP -= max(Target.Counter - Selected.Defense, 0);
						
						SelectedState = 3.2;
					}
					ds_list_destroy(targets);
				}
				
				
				// Otherwise, delete the Target
				// and end turn
				else
				{
					instance_destroy(Target);
					
					// End unit's turn
					Selected.Moved = true;
					Selected = noone;
					SelectedState = 0;
					
					Map.update_unitgrid();
				}
			}
			break;
			
		
		
		// Selected unit slash anim (counterattack)
		case 3.2:
			if (Selected.DrawSlash <= -1)
			{
				// Check if Selected is still alive
				if (Selected.HP > 0) Selected.Moved = true;
				
				// Otherwise, delete Selected
				else instance_destroy(Selected);
				
				
				// End unit's turn
				Selected = noone;
				SelectedState = 0;
				
				Map.update_unitgrid();
			}
			break;
	}
}

// -------------------- //

global.Frame += 1;

state_machine();