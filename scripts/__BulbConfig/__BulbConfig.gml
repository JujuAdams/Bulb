//Distance around the edge of the camera (in pixels) to draw dynamic occluders. Increase this
//number if you have large dynamic occluders and are experiencing pop-in.
#macro BULB_DYNAMIC_OCCLUDER_RANGE  100

//Adds an extra triangle for each occluder to compensate for situations where a light might be very
//close to an occluder. Normally, this would cause light to bleed through the wall. Setting this
//macro to <true> will solve near-light problems but does incur a slight performance penalty.
#macro BULB_COMPENSATE_FOR_NEAR_OCCLUDERS  false

#macro BULB_DEFAULT_NORMAL_MAP_ALPHA_THRESHOLD  0.5

#macro BULB_DEFAULT_NORMAL_MAP_Z  0.2

#macro BULB_DEFAULT_USE_NORMAL_MAP  true