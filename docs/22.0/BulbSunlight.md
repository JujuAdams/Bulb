# BulbSunlight

&nbsp;

`BulbSunlight(renderer, angle)` ***constructor***

**Constructor returns:** `BulbSunlight` struct

|Argument  |Datatype    |Purpose                      |
|----------|------------|-----------------------------|
|`renderer`|renderer    |Renderer to add this light to|
|`angle`   |number      |Direction of the light       |

This type of light is a directional light source which covers the entire renderer with shadows radiating in one direction. Directional lights always cast shadows. When attached to a renderer that is using soft shadows, the size of a sunlight's penumbra can be adjusted too. This is helpful when simulating broad light sources such as windows or fireplaces.

A light's intensity is typically a value from `0` to `1` but when using HDR rendering, a light's intensity can exceed `1` to represent very bright light sources. Lights can be affected by a normal map too, should one be set up, and a light's "height" over the normal map can be adjusted too which changes how strongly the normal mapping effect is.

When created, a `BulbSunlight` will be added to the given renderer. A light can be added (and removed) from multiple renderers as you see fit.

?> You must maintain a reference to a created `BulbSunlight` yourself. Bulb tracks lights using a **weak reference** such that when you discard the reference to the light, the light is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep a light alive.

&nbsp;

## Member Variables

The created struct has the following public member variables:

|Variable      |Datatype|Purpose                                                                                   |
|--------------|--------|------------------------------------------------------------------------------------------|
|`angle`       |number  |Direction of the light                                                                    |
|`blend`       |integer |Blend colour to use for the light                                                         |
|`intensity`   |number  |Brightness of the light. `0` is completely invisible. Values higher than `1` will render incorrectly unless the renderer is operating in HDR mode|
|`visible`     |boolean |Whether to draw the light at all                                                          |
|`penumbraSize`|number  |Size of the penumbra when using the `BULB_MODE.SOFT_BM_ADD` rendering mode                |
|`normalMap`   |boolean |Whether the light should respect the normal map. Defaults to `BULB_DEFAULT_USE_NORMAL_MAP` (which itself defaults to `false`)|
|`normalMapZ`  |number  |The "z" component of the light for purposes of normal mapping. Defaults to `BULB_DEFAULT_NORMAL_MAP_Z` (which itself defaults to `0.2`)|

&nbsp;

## .AddToRenderer()

`.AddToRenderer(renderer)`

**Returns:** N/A (`undefined`)

|Argument  |Datatype|Purpose                         |
|----------|--------|--------------------------------|
|`renderer`|renderer|Renderer to add this occluder to|

&nbsp;

## .RemoveFromRenderer()

`.RemoveFromRenderer(renderer)`

**Returns:** N/A (`undefined`)

|Argument  |Datatype|Purpose                         |
|----------|--------|--------------------------------|
|`renderer`|renderer|Renderer to add this occluder to|

&nbsp;

## .Destroy()

`.Destroy()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Instantly destroys the light and prevents it from being drawn.