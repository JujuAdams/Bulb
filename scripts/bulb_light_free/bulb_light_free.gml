/// Cleans up any allocated data structures/surfaces that a light has created
/// Must be called after bulb_set_as_light()
/// 
/// return: Nothing
/// 
/// This code and engine are provided under the Creative Commons "Attribution - NonCommerical - ShareAlike" international license.
/// https://creativecommons.org/licenses/by-nc-sa/4.0/

function bulb_light_free()
{
    if ((__bulb_light_surface != undefined) && surface_exists(__bulb_light_surface))
    {
        surface_free(__bulb_light_surface);
    }
}