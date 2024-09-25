// Distance around the edge of the camera (in pixels) to draw dynamic occluders. Increase this
// number if you have large dynamic occluders and are experiencing pop-in.
#macro BULB_DYNAMIC_OCCLUDER_RANGE  100

// Adds an extra triangle for each occluder to compensate for situations where a light might be
// very close to an occluder. Normally, this would cause light to bleed through the wall. Setting
// this macro to `true` will solve near-light problems but does incur a slight performance penalty.
#macro BULB_COMPENSATE_FOR_NEAR_OCCLUDERS  false

// Whether renderers, lights, and sunlight should default to having normal map support enabled.
// This saves a lot of time setting `.normalMap` on everything that you create. Enabling normal
// maps has a significant performance penalty so use this carefully.
#macro BULB_DEFAULT_USE_NORMAL_MAP  false

// The alpha threshold for sprites when drawing to the normal/specular map. Anything below this
// value will be discarded by the shader.
#macro BULB_NORMAL_MAP_ALPHA_THRESHOLD  0.5

// How intense the specular map effect should be. This generally is only noticeable when using HDR
// lighting. The specular map is packed into the alpha channel of the normal map surface.
#macro BULB_SPECULAR_MAP_INTENSITY  10.0

// The default notional "z height" for lights and sunlight. This z value is only used when
// calculating normal map influence on lights. A lower value brings the light closer to the plane,
// leading to a shallower angle of attack. This leads to more intense normal maps where the edges
// of shapes will be highlighted more strongly than the tops of shapes, especially at distance.
#macro BULB_DEFAULT_NORMAL_MAP_Z  0.2