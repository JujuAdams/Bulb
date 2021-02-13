//Other controls
if (keyboard_check_pressed(vk_escape)) game_end();

if (keyboard_check_pressed(vk_f1))
{
    showDebug = !showDebug;
    show_debug_overlay(showDebug);
}

if (keyboard_check_pressed(ord("L"))) instance_create_depth(oPlayer.x, oPlayer.y, 0, oLightDiscoooo);

if ((keyboard_check(ord("T"))) && (fps_real > 61) && (fps > 55)) instance_create_depth(oPlayer.x, oPlayer.y, 0, oLightDiscoooo);

if (keyboard_check_pressed(ord("1"))) with(oLightDiscoooo) light.visible = !light.visible;

if (keyboard_check_pressed(ord("2"))) lighting.mode = (lighting.mode + 1) mod BULB_MODE.__SIZE;

//Update debug timers
if (alarm_get(1) < 0)
{
    smoothedFrameTime = lerp(smoothedFrameTime, 1000/fps_real, 0.005);
    smoothedFPS = lerp(smoothedFPS, fps_real, 0.005);
    smoothedDrawEndTime = lerp(smoothedDrawEndTime, drawEndTime, 0.005);
}