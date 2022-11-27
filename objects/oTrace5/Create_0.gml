occluder        = new BulbDynamicOccluder(oRenderer5.lighting);
occluder.x      = x;
occluder.y      = y;
occluder.xscale = image_xscale;
occluder.yscale = image_yscale;
occluder.angle  = image_angle;

loopArray = BulbSpriteEdgeTrace(sprite_index, image_index);
BulbSpriteEdgeAddToOccluder(occluder, loopArray);