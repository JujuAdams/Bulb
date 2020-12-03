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
    __bulb_light_width         = sprite_get_width( sprite_index);
    __bulb_light_height        = sprite_get_height(sprite_index);
    __bulb_light_width_half    = 0.5*__bulb_light_width;
    __bulb_light_height_half   = 0.5*__bulb_light_height;
    __bulb_on_screen           = true;
    __bulb_light_deferred      = _deferred;
    __bulb_light_surface       = undefined;
    __bulb_light_penumbra_size = BULB_PENUMBRA_SIZE;
}