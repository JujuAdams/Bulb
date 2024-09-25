//Draw the debug overlay
DebugOverlay();

var _colour = renderer.GetLightValue(mouse_x, mouse_y);
draw_set_colour(_colour);
draw_rectangle(display_get_gui_width() - 60, 10, display_get_gui_width() - 10, 60, false);
draw_set_colour(c_white);