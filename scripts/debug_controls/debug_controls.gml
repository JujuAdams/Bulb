function debug_controls()
{
    if (keyboard_check_pressed(vk_escape)) game_end();

    if (keyboard_check_pressed(vk_f1))
    {
        show_debug = !show_debug;
        show_debug_overlay(show_debug);
    }

    if (keyboard_check_pressed(ord("L"))) instance_create_depth(x, y, 0, obj_light_discoooo);
    
    if ((keyboard_check(ord("T"))) && (fps_real > 61) && (fps > 59)) instance_create_depth(x, y, 0, obj_light_discoooo);
    
    if (keyboard_check_pressed(ord("1"))) with(obj_light_discoooo) visible = !visible;
    
    if (keyboard_check_pressed(ord("2"))) lighting.self_lighting = !lighting.self_lighting;
    
    if (keyboard_check_pressed(ord("3")))
    {
        lighting.mode = (lighting.mode + 1) mod LIGHTING_MODE.__SIZE;
        lighting.free_vertex_buffers();
    }
    
    if (keyboard_check_pressed(ord("4"))) lighting.partial_clear = !lighting.partial_clear;
    
    if (keyboard_check_pressed(ord("5"))) lighting.force_deferred = !lighting.force_deferred;
}