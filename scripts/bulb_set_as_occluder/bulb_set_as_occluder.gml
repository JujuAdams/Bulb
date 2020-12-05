/// Initialises some variables and an array that describe a occluding (shadow-casting) instance
/// This function should be called in every instance/object that occludes light

function bulb_set_as_occluder()
{
    __bulb_edge_count = 0;
    __bulb_vertex_array = [];
    __bulb_on_screen    = true;
}