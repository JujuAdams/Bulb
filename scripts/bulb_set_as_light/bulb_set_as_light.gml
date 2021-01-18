/// Initialises some variables that describe a light emitter
/// This function should be called in every instance/object that emits light. The colour/size/rotation of the light is derived from image_xscale, image_blend etc.
///
/// @param [penumbraSize]   The penumbra size for the light emitter, 0 being no penumbra (effectively the "width" of the light)
///                         This value should be smaller than the smallest occluding instance. Shadows penumbra will only be drawn in BULB_MODE.SOFT_BM_ADD mode
/// @param [castShadows]    Whether this light should cast a shadow

function bulb_set_as_light()
{
    var _penumbra_size = ((argument_count > 0) && (argument[0] != undefined))? argument[0] : 0;
    var _cast_shadows  = ((argument_count > 1) && (argument[1] != undefined))? argument[1] : true;
    
    __bulb_light_penumbra_size = _penumbra_size;
    __bulb_cast_shadows        = _cast_shadows;
    
    __bulb_light_width         = sprite_get_width(sprite_index);
    __bulb_light_height        = sprite_get_height(sprite_index);
    __bulb_light_width_half    = 0.5*__bulb_light_width;
    __bulb_light_height_half   = 0.5*__bulb_light_height;
    __bulb_on_screen           = true;
}