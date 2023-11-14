# BulbSunlight

&nbsp;

`BulbSunlight(renderer, angle)` ***constructor***

**Constructor returns:** `BulbSunlight` struct

|Argument  |Datatype    |Purpose                      |
|----------|------------|-----------------------------|
|`renderer`|renderer    |Renderer to add this light to|
|`angle`   |number      |Direction of the light       |

When created, a `BulbSunlight` will be added to the given renderer. A light can be added (and removed) from multiple renderers as you see fit.

?> You must maintain a reference to a created `BulbSunlight` yourself. Bulb tracks lights using a **weak reference** such that when you discard the reference to the light, the light is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep a light alive.

&nbsp;

## Member Variables

The created struct has the following public member variables:

|Variable      |Datatype      |Purpose                                                                          |
|--------------|--------------|---------------------------------------------------------------------------------|
|`angle`       |number        |Direction of the light                                                           |
|`blend`       |integer       |Blend colour to use for the light                                                |
|`alpha`       |number        |Transparency value for the light, from `0.0` (invisible) to `1.0` (fully visible)|
|`visible`     |boolean       |Whether to draw the light at all                                                 |
|`penumbraSize`|number        |Size of the penumbra when using the `BULB_MODE.SOFT_BM_ADD` rendering mode       |

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