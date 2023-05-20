# BulbShadowOverlay

&nbsp;

`BulbShadowOverlay(renderer, sprite, image, x, y)` ***constructor***

**Constructor returns:** `BulbShadowOverlay` struct

|Name      |Datatype    |Purpose                                                                       |
|----------|------------|------------------------------------------------------------------------------|
|`renderer`|renderer    |Renderer to add this occluder to                                              |
|`sprite`  |sprite index|Sprite to draw for the light                                                  |
|`image`   |number      |Image index of the given sprite to draw. Negative values are **not** supported|
|`x`       |number      |x-position of the light                                                       |
|`y`       |number      |y-position of the light                                                       |

When created, a `BulbShadowOverlay` will be added to the given renderer. An overlay can be added (and removed) from multiple renderers as you see fit.

?> You must maintain a reference to a created `BulbShadowOverlay` yourself. Bulb tracks overlays using a **weak reference** such that when you discard the reference to the overlay, the overlay is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep a overlay alive.

&nbsp;

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

The created struct has the following methods (click to expand):

<details><summary><code>.AddToRenderer(renderer)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype|Purpose                         |
|----------|--------|--------------------------------|
|`renderer`|renderer|Renderer to add this occluder to|

&nbsp;
</details>

<details><summary><code>.RemoveFromRenderer(renderer)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype|Purpose                         |
|----------|--------|--------------------------------|
|`renderer`|renderer|Renderer to add this occluder to|

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