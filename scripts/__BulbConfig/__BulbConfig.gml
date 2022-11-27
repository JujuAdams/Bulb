//Distance around the edge of the camera (in pixels) to draw dynamic occluders
//Increase this number if you have large dynamic occluders and are experiencing pop-in
#macro BULB_DYNAMIC_OCCLUDER_RANGE  100

//Default group bitmasks to use for each type of constructor
//N.B. Group bitmasks will only be considered when rendering using BulbRendererWithGroups()
//0xFFFFFFFFFFFFFFFF will put a light/occluder in every possible group
#macro BULB_DEFAULT_LIGHT_BITMASK   0xFFFFFFFFFFFFFFFF
#macro BULB_DEFAULT_STATIC_BITMASK  0xFFFFFFFFFFFFFFFF
#macro BULB_DEFAULT_DYNAMIC_BITMASK 0xFFFFFFFFFFFFFFFF

#macro BULB_VERBOSE  true

#macro BULB_SPRITE_EDGE_AUTOTRACE  true
#macro BULB_SPRITE_AUTOTRACE_TAG   "bulb trace"

#macro BULB_SPRITE_EDGE_AUTOTAG  true

#macro BULB_DISK_CACHE  true

#macro BULB_FORCE_PRODUCTION  false