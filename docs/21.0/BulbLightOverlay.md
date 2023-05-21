# BulbLightOverlay

&nbsp;

`BulbLightOverlay(renderer, sprite, image, x, y)` ***constructor***

**Constructor returns:** `BulbLightOverlay` struct

|Argument  |Datatype    |Purpose                                                                       |
|----------|------------|------------------------------------------------------------------------------|
|`renderer`|renderer    |Renderer to add this occluder to                                              |
|`sprite`  |sprite index|Sprite to draw for the light                                                  |
|`image`   |number      |Image index of the given sprite to draw. Negative values are **not** supported|
|`x`       |number      |x-position of the light                                                       |
|`y`       |number      |y-position of the light                                                       |

When created, a `BulbLightOverlay` will be added to the given renderer. A light can be added (and removed) from multiple renderers as you see fit.

?> You must maintain a reference to a created `BulbLightOverlay` yourself. Bulb tracks lights using a **weak reference** such that when you discard the reference to the light, the light is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep a light alive.

&nbsp;

## Member Variables

The created struct has the following public member variables:

|Variable |Datatype    |Purpose                                                                          |
|---------|------------|---------------------------------------------------------------------------------|
|`sprite` |sprite index|Sprite to draw for the light                                                     |
|`image`  |number      |Image index of the given sprite to draw. Negative values are **not** supported   |
|`x`      |number      |x-position of the light                                                          |
|`y`      |number      |y-position of the light                                                          |
|`xscale` |number      |Horizontal scaling of the light                                                  |
|`yscale` |number      |Vertical scaling of the light                                                    |
|`angle`  |number      |Rotation of the light                                                            |
|`blend`  |integer     |Blend colour to use for the light                                                |
|`alpha`  |number      |Transparency value for the light, from `0.0` (invisible) to `1.0` (fully visible)|
|`visible`|boolean     |Whether to draw the light at all                                                 |

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