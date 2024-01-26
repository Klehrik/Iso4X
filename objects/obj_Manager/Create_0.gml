/// obj_Manager : Init

#macro CAM_W camera_get_view_width(view_camera[0])
#macro CAM_H camera_get_view_height(view_camera[0])

randomize();
draw_set_font(fnt_PICO8);
draw_set_circle_precision(64);

global.Frame = 0;



Map = instance_create_depth(0, 0, 0, obj_Isometric);
Map.load_map(1);
Map.init_grid();
Map.init_unitgrid();

Selected = noone;
SelectedState = 0;
SelectedTargets = -1;
Target = noone;