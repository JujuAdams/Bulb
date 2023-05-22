//Distance around the edge of the camera (in pixels) to draw dynamic occluders
//Increase this number if you have large dynamic occluders and are experiencing pop-in
#macro BULB_DYNAMIC_OCCLUDER_RANGE  100

//Controls how shadow overlays (created with the BulbShadowOverlay() constructor) are drawn
//The default value is <true>, where the HSV value (calculated as max(r,g,b)) is converted into an alpha value
//This is analogous to a lighting sprite, only when using as a shadow overlay sprite, the effect is subtractive
//If set to <false> then the alpha channel of the sprite is used instead (and the RGB channels are ignored)
#macro BULB_SHADOW_OVERLAY_HSV_VALUE_TO_ALPHA  true

//Whether to output extra information about Bulb to the output log
#macro BULB_VERBOSE  true

//Alpha threshold to use when tracing the outlines of sprites and tilesets
//Any value greater than or equal to this alpha threshold is considered "opaque"
#macro BULB_TRACE_ALPHA_THRESHOLD  0.1

//Bulb uses the Ramer–Douglas–Peucker algorithm algorithm to clean up sprite and tilemap tracings
//You'll only notice the impact of this macro when using a self-lighting renderer mode
//Increase this number to reduce the number of unnecessary shadows. Decrease this number if you seem to be missing shadows
#macro BULB_TRACE_EPSILON  4

//Whether to automatically trace tagged assets on boot, and what that tag should be
//  N.B. In GameMaker LTS 2022.0.0.12, this feature will not work for tilesets due to an upstream GameMaker bug
#macro BULB_TRACE_TAGGED_ASSETS_ON_BOOT  true
#macro BULB_TRACE_TAG  "bulb trace"

//Whether to automatically tag assets for tracing on boot (see BULB_TRACE_TAGGED_ASSETS_ON_BOOT above)
//This is a convenience feature to help make using the trace-on-boot feature easier to use
//The tag that is added to assets is additive with any existing tags
//This feature only works with the Windows, MacOS, and Linux exports and when running from the IDE
#macro BULB_TAG_ASSETS_ON_USE  true

//Whether to cache sprite/tileset outlines to disk the first time they are used - this includes the
//first time an asset is automatically traced on boot. Using the disk cache speeds up outline tracing
//Asset outlines in the cache are invalidated in two situations:
// 
// 1. When running from the IDE, if the sprite image or tileset has visibly changed
// 
// 2. When running from an executable, if the build date of the executable has changed
//    This means that the disk cache will be fully refreshed every time you distribute a new build
//
//  N.B. This feature has not been tested on console. Please conduct full testing before use cross-platform
#macro BULB_USE_DISK_CACHE  false