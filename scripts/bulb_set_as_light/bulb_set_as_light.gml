/// Initialises the necessary variables for a light object to use the lighting system.
/// Must be called before bulb_light_free().
/// 
/// return: Nothing
/// 
/// This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
/// https://creativecommons.org/licenses/by-nc-sa/4.0/
///
/// @param deferred

function bulb_set_as_light(_deferred)
{
    light_w             = sprite_get_width( sprite_index);
    light_h             = sprite_get_height(sprite_index);
    light_w_half        = 0.5*light_w;
    light_h_half        = 0.5*light_h;
    light_on_screen     = true;
    light_deferred      = _deferred;
    light_surface       = undefined;
    light_penumbra_size = BULB_PENUMBRA_SIZE;
}