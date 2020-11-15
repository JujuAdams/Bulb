/// Cleans up any allocated data structures/surfaces that a light has created
/// Must be called after lighting_set_as_light()
/// 
/// return: Nothing
/// 
/// This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
/// https://creativecommons.org/licenses/by-nc-sa/4.0/

function lighting_light_free()
{
    if ((light_surface != undefined) && surface_exists(light_surface))
    {
        surface_free(light_surface);
    }
}