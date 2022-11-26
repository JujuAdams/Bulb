occluder        = new BulbDynamicOccluder(oRenderer5.lighting);
occluder.x      = x;
occluder.y      = y;
occluder.xscale = image_xscale;
occluder.yscale = image_yscale;
occluder.angle  = image_angle;

var _t = get_timer();
loopArray = BulbSpriteEdgeTrace(sprite_index, image_index);
show_debug_message(get_timer() - _t);

var _t = get_timer();
BulbSpriteEdgeSimplify(loopArray);
show_debug_message(get_timer() - _t);

BulbSpriteEdgeAddToOccluder(occluder, loopArray);