# BulbPointLight

&nbsp;

`BulbLight(renderer, sprite, image, x, y)` ***constructor***

**Constructor returns:** `BulbLight` struct

|Argument  |Datatype    |Purpose                                                                       |
|----------|------------|------------------------------------------------------------------------------|
|`renderer`|renderer    |Renderer to add this occluder to                                              |
|`sprite`  |sprite index|Sprite to draw for the light                                                  |
|`image`   |number      |Image index of the given sprite to draw. Negative values are **not** supported|
|`x`       |number      |x-position of the light                                                       |
|`y`       |number      |y-position of the light                                                       |

When created, a `BulbLight` will be added to the given renderer. A light can be added (and removed) from multiple renderers as you see fit.

?> You must maintain a reference to a created `BulbLight` yourself. Bulb tracks lights using a **weak reference** such that when you discard the reference to the light, the light is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep a light alive.

&nbsp;

## Member Variables

The created struct has the following public member variables:

|Variable      |Datatype    |Purpose                                                                                   |
|--------------|------------|------------------------------------------------------------------------------------------|
|`sprite`      |sprite index|Sprite to draw for the light                                                              |
|`image`       |number      |Image index of the given sprite to draw. Negative values are **not** supported            |
|`x`           |number      |x-position of the light                                                                   |
|`y`           |number      |y-position of the light                                                                   |
|`xscale`      |number      |Horizontal scaling of the light                                                           |
|`yscale`      |number      |Vertical scaling of the light                                                             |
|`angle`       |number      |Rotation of the light                                                                     |
|`blend`       |integer     |Blend colour to use for the light                                                         |
|`intensity`   |number      |Brightness of the light. `0` is completely invisible. Values higher than `1` will render incorrectly unless the renderer is operating in HDR mode|
|`visible`     |boolean     |Whether to draw the light at all                                                          |
|`castShadows` |boolean     |Whether the light casts shadow. Not casting shadows is much faster!                       |
|`penumbraSize`|number      |Size of the penumbra when using the `BULB_MODE.SOFT_BM_ADD` rendering mode                |
|`normalMap`   |boolean     |Whether the light should respect the normal map. Defaults to `BULB_DEFAULT_USE_NORMAL_MAP`|
|`normalMapZ`  |number      |The "z" component of the light for purposes of normal mapping. Defaults to `BULB_DEFAULT_NORMAL_MAP_Z`|

&nbsp;

## .AddToRenderer

`.AddToRenderer(renderer)`

**Returns:** N/A (`undefined`)

|Argument  |Datatype|Purpose                         |
|----------|--------|--------------------------------|
|`renderer`|renderer|Renderer to add this occluder to|

&nbsp;

## .RemoveFromRenderer

`.RemoveFromRenderer(renderer)`

**Returns:** N/A (`undefined`)

|Argument  |Datatype|Purpose                         |
|----------|--------|--------------------------------|
|`renderer`|renderer|Renderer to add this occluder to|

&nbsp;

## .Destroy

`.Destroy()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Instantly destroys the light and prevents it from being drawn.
