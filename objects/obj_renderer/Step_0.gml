//Other controls
if (keyboard_check_pressed(vk_escape)) game_end();

if (keyboard_check_pressed(vk_f1))
{
    show_debug = !show_debug;
    show_debug_overlay(show_debug);
}

if (keyboard_check_pressed(ord("L"))) instance_create_depth(obj_player.x, obj_player.y, 0, obj_light_discoooo);

if ((keyboard_check(ord("T"))) && (fps_real > 61) && (fps > 55)) instance_create_depth(obj_player.x, obj_player.y, 0, obj_light_discoooo);

if (keyboard_check_pressed(ord("1"))) with(obj_light_discoooo) visible = !visible;

if (keyboard_check_pressed(ord("2"))) lighting.mode = (lighting.mode + 1) mod BULB_MODE.__SIZE;

//Update debug timers
if (alarm_get(1) < 0)
{
    smoothed_frame_time = lerp(smoothed_frame_time, 1000/fps_real, 0.005);
    smoothed_fps = lerp(smoothed_fps, fps_real, 0.005);
    smoothed_draw_end_time = lerp(smoothed_draw_end_time, draw_end_time, 0.005);
}