# BulbAmbienceSprite

&nbsp;

`BulbAmbienceSprite(renderer)` ***constructor***

**Constructor returns:** `BulbAmbienceSprite` struct

|Argument  |Datatype    |Purpose                                |
|----------|------------|---------------------------------------|
|`renderer`|renderer    |Renderer to add this ambience sprite to|

Ambience sprites are used to adjust the ambient colour in particular regions of a room. Ambience sprites are drawn over the top of the ambient colour (set on the renderer) and underneath any lights and overlays. Ambience sprites are useful for creating ambient occlusion to give a subtle illusion of depth. You can also dark ambient sprites with a bright ambient colour to mask out particular areas e.g. the inside of buildings are dark but the outside lighting is bright.

When created, a `BulbAmbienceSprite` will be added to the given renderer. Ambience sprites are drawn one after another using the `bm_normal` blend mode in the order that they are added to the renderer. An ambience sprite can be added (and removed) from multiple renderers as you see fit.

?> You must maintain a reference to a created `BulbAmbienceSprite` yourself. Bulb tracks ambience sprites using a **weak reference** such that when you discard the reference to the overlay, the overlay is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep an ambience sprite alive.

&nbsp;

## Member Variables

The created struct has the following public member variables:
  
|Variable |Datatype    |Purpose                                                                           |
|---------|------------|----------------------------------------------------------------------------------|
|`sprite` |sprite index|Sprite to draw                                                                    |
|`image`  |number      |Image index of the given sprite to draw. Negative values are **not** supported    |
|`x`      |number      |x-position of the sprite                                                          |
|`y`      |number      |y-position of the sprite                                                          |
|`xscale` |number      |Horizontal scaling of the sprite                                                  |
|`yscale` |number      |Vertical scaling of the sprite                                                    |
|`angle`  |number      |Rotation of the sprite                                                            |
|`blend`  |integer     |Blend colour to use for the light                                                 |
|`alpha`  |number      |Transparency value for the sprite, from `0.0` (invisible) to `1.0` (fully visible)|
|`visible`|boolean     |Whether to draw the sprite at all                                                 |

&nbsp;

## .AddToRenderer

`.AddToRenderer(renderer)`

**Returns:** N/A (`undefined`)

|Argument  |Datatype|Purpose                                |
|----------|--------|---------------------------------------|
|`renderer`|renderer|Renderer to add this ambience sprite to|

&nbsp;

## .RemoveFromRenderer

`.RemoveFromRenderer(renderer)`

**Returns:** N/A (`undefined`)

|Argument  |Datatype|Purpose                                |
|----------|--------|---------------------------------------|
|`renderer`|renderer|Renderer to add this ambience sprite to|

&nbsp;

## .Destroy

`.Destroy()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Instantly destroys the ambience sprite and prevents it from being drawn.