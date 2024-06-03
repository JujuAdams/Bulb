# BulbShadowOverlay

&nbsp;

`BulbShadowOverlay(renderer)` ***constructor***

**Constructor returns:** `BulbShadowOverlay` struct

|Argument  |Datatype    |Purpose                               |
|----------|------------|--------------------------------------|
|`renderer`|renderer    |Renderer to add this shadow overlay to|

When created, a `BulbShadowOverlay` will be added to the given renderer. An overlay can be added (and removed) from multiple renderers as you see fit.

?> You must maintain a reference to a created `BulbShadowOverlay` yourself. Bulb tracks overlays using a **weak reference** such that when you discard the reference to the overlay, the overlay is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep a overlay alive.

&nbsp;

## Member Variables

The created struct has the following public member variables:
  
|Variable |Datatype    |Purpose                                                                            |
|---------|------------|-----------------------------------------------------------------------------------|
|`sprite` |sprite index|Sprite to draw for the overlay                                                     |
|`image`  |number      |Image index of the given sprite to draw. Negative values are **not** supported     |
|`x`      |number      |x-position of the overlay                                                          |
|`y`      |number      |y-position of the overlay                                                          |
|`xscale` |number      |Horizontal scaling of the overlay                                                  |
|`yscale` |number      |Vertical scaling of the overlay                                                    |
|`angle`  |number      |Rotation of the overlay                                                            |
|`alpha`  |number      |Transparency value for the overlay, from `0.0` (invisible) to `1.0` (fully visible)|
|`visible`|boolean     |Whether to draw the overlay at all                                                 |

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
