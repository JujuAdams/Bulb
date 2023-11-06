### `BulbLight(renderer, sprite, image, x, y)` ***constructor***

**Constructor returns:** `BulbLight` struct

|Name      |Datatype                                                                   |Purpose                                                                       |
|----------|---------------------------------------------------------------------------|------------------------------------------------------------------------------|
|`renderer`|[renderer](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor)|Renderer to add this occluder to                                              |
|`sprite`  |sprite index                                                               |Sprite to draw for the light                                                  |
|`image`   |real                                                                       |Image index of the given sprite to draw. Negative values are **not** supported|
|`x`       |real                                                                       |x-position of the light                                                       |
|`y`       |real                                                                       |y-position of the light                                                       |

When created, a `BulbLight` will be added to the given renderer. A light can be added (and removed) from multiple renderers as you see fit.

?> You must maintain a reference to a created `BulbLight` yourself. Bulb tracks lights using a **weak reference** such that when you discard the reference to the light, the light is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep a light alive.

The created struct has the following public member variables:

|Variable      |Datatype      |Purpose                                                                                                                                                     |
|--------------|--------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`sprite`      |sprite index  |Sprite to draw for the light                                                                                                                                |
|`image`       |real          |Image index of the given sprite to draw. Negative values are **not** supported                                                                              |
|`x`           |real          |x-position of the light                                                                                                                                     |
|`y`           |real          |y-position of the light                                                                                                                                     |
|`xscale`      |real          |Horizontal scaling of the light                                                                                                                             |
|`yscale`      |real          |Vertical scaling of the light                                                                                                                               |
|`angle`       |real          |Rotation of the light                                                                                                                                       |
|`blend`       |integer       |Blend colour to use for the light                                                                                                                           |
|`alpha`       |real          |Transparency value for the light, from `0.0` (invisible) to `1.0` (fully visible)                                                                           |
|`visible`     |boolean       |Whether to draw the light at all                                                                                                                            |
|`castShadows` |boolean       |Whether the light casts shadow. Not casting shadows is much faster!                                                                                         |
|`penumbraSize`|real          |Size of the penumbra when in using the `BULB_MODE.SOFT_BM_ADD` rendering mode                                                                               |
|`bitmask`     |64-bit integer|Which groups of occluders to render for this light. [BulbMakeBitmask()](GML-Functions#bulbmakebitmaskgroup1-group2-group3-) can be used to generate bitmasks|

The created struct has the following methods (click to expand):

<details><summary><code>.AddToRenderer(renderer)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype                                                                   |Purpose                      |
|----------|---------------------------------------------------------------------------|-----------------------------|
|`renderer`|[renderer](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor)|Renderer to add this light to|

&nbsp;
</details>

<details><summary><code>.RemoveFromRenderer(renderer)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype                                                                   |Purpose                            |
|----------|---------------------------------------------------------------------------|-----------------------------------|
|`renderer`|[renderer](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor)|Renderer to removed this light from|

&nbsp;
</details>

<details><summary><code>.Destroy()</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Instantly destroys the light and prevents it from being drawn.

&nbsp;
</details>