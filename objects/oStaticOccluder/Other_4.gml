occluder        = BulbCreateStaticOccluder(oRenderer.lighting);
occluder.x      = x;
occluder.y      = y;
occluder.xscale = image_xscale;
occluder.yscale = image_yscale;
occluder.angle  = image_angle;

var _l = -0.5*sprite_get_width(sprite_index);
var _t = -0.5*sprite_get_height(sprite_index);
var _r =  0.5*sprite_get_width(sprite_index);
var _b =  0.5*sprite_get_height(sprite_index);

if ((image_angle != 0) || (image_xscale != 1) || (image_yscale != 1))
{
    //If this instance has been rotated or stretched in the room editor, add every side as an occluder
    //Use clockwise definitions!
    occluder.addEdge(_l, _t,   _r, _t); //Top
    occluder.addEdge(_r, _t,   _r, _b); //Right
    occluder.addEdge(_r, _b,   _l, _b); //Bottom
    occluder.addEdge(_l, _b,   _l, _t); //Left
}
else
{
    //If this instance is axis-aligned and non-stretched, only add shadow casting sides if they're external
    //Use clockwise definitions!
    if (!position_meeting(x, y - 32, oStaticOccluder)) occluder.addEdge(_l, _t,   _r, _t); //Top
    if (!position_meeting(x + 32, y, oStaticOccluder)) occluder.addEdge(_r, _t,   _r, _b); //Right
    if (!position_meeting(x, y + 32, oStaticOccluder)) occluder.addEdge(_r, _b,   _l, _b); //Bottom
    if (!position_meeting(x - 32, y, oStaticOccluder)) occluder.addEdge(_l, _b,   _l, _t); //Left
}