/// Structures

// Indexes corresponding to image_index in spr_Structure
enum TileStructures
{
	tree,
	rock,
	capital_blue,
	capital_red
}



function get_structure(ID)
{
	switch (ID)
	{
		case TileStructures.capital_blue:
			return {
				Health: 9
			}
			break;
			
		case TileStructures.capital_red:
			return {
				Health: 9
			}
			break;
	}
}