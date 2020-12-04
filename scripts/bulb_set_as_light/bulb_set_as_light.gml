/// Initialises the necessary variables for a light object to use the lighting system
///
/// @param [penumbraSize]

function bulb_set_as_light()
{
    var _penumbra_size = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : 0;
    
    __bulb_light_width         = sprite_get_width(sprite_index);
    __bulb_light_height        = sprite_get_height(sprite_index);
    __bulb_light_width_half    = 0.5*__bulb_light_width;
    __bulb_light_height_half   = 0.5*__bulb_light_height;
    __bulb_on_screen           = true;
    __bulb_light_penumbra_size = _penumbra_size;
}