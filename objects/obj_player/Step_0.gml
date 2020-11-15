//Player input
player_controls();

//Other controls
debug_controls();

//Update camera position
camera_set_view_pos(camera, round(x - 0.5*camera_get_view_width(camera)), round(y - 0.5*camera_get_view_height(camera)));

//Update debug timers
if (alarm_get(1) < 0)
{
    smoothed_frame_time = lerp(smoothed_frame_time, 1000/fps_real, 0.005);
    smoothed_fps = lerp(smoothed_fps, fps_real, 0.005);
    smoothed_draw_end_time = lerp(smoothed_draw_end_time, draw_end_time, 0.005);
}