//Draw the debug overlay
DebugOverlay();

var _colour = lighting.GetSurfacePixelFromCamera(mouse_x, mouse_y, camera);
draw_set_colour(_colour);
draw_rectangle(display_get_gui_width() - 110, 10, display_get_gui_width() - 10, 110, false);
draw_set_colour(c_white);