occluder        = new BulbStaticOccluder(oRenderer.lighting);
occluder.x      = x;
occluder.y      = y;
occluder.xscale = image_xscale;
occluder.yscale = image_yscale;
occluder.angle  = image_angle;
occluder.AddSprite(sprite_index, image_index);