//Distance around the edge of the camera (in pixels) to draw dynamic occluders
//Increase this number if you have large dynamic occluders and are experiencing pop-in
#macro BULB_DYNAMIC_OCCLUDER_RANGE  100

//Default group bitmasks to use for each type of constructor
//N.B. Group bitmasks will only be considered when rendering using BulbRendererWithGroups()
//0xFFFFFFFFFFFFFFFF will put a light/occluder in every possible group
#macro BULB_DEFAULT_LIGHT_BITMASK   0xFFFFFFFFFFFFFFFF
#macro BULB_DEFAULT_STATIC_BITMASK  0xFFFFFFFFFFFFFFFF
#macro BULB_DEFAULT_DYNAMIC_BITMASK 0xFFFFFFFFFFFFFFFF

//Controls how shadow overlays (created with the BulbShadowOverlay() constructor) are drawn
//The default value is <true>, where the HSV value (calculated as max(r,g,b)) is converted into an alpha value
//This is analogous to a lighting sprite, only when using as a shadow overlay sprite, the effect is subtractive
//If set to <false> then the alpha channel of the sprite is used instead (and the RGB channels are ignored)
#macro BULB_SHADOW_OVERLAY_HSV_VALUE_TO_ALPHA  true