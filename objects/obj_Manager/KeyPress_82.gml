/// Reset

with (obj_Isometric)
{
	ds_grid_destroy(Grid);
	ds_grid_destroy(UnitGrid);
}

with (obj_Unit)
{
	ds_grid_destroy(PathMap);
	ds_list_destroy(MovePath);
}

room_restart();