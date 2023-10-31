### `BulbDynamicOccluder(renderer)` ***constructor***

**Constructor returns:** `BulbDynamicOccluder` struct

|Name      |Datatype                                                                   |Purpose                         |
|----------|---------------------------------------------------------------------------|--------------------------------|
|`renderer`|[renderer](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor)|Renderer to add this occluder to|

When created, a `BulbDynamicOccluder` will be added to the given renderer. An occluder can be added (and removed) from multiple renderers as you see fit.

When dynamic occluders are drawn is controlled, in part, by `BULB_DYNAMIC_OCCLUDER_RANGE` found in `__BulbConfig()`. If you have large dynamic occluders and you're experiencing pop-in, increase this value.

**Please note** that you must maintain a reference to a created `BulbDynamicOccluder` yourself. Bulb tracks occluders using a **weak reference** such that when you discard the reference to the occluder, the occluder is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep an occluder alive.

The created struct has the following public member variables:

|Variable     |Datatype      |Purpose                                                                                                                                           |
|-------------|--------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
|`visible`    |boolean       |Whether to draw the occluder at all                                                                                                               |
|`x`          |real          |x-position of the occluder                                                                                                                        |
|`y`          |real          |x-position of the occluder                                                                                                                        |
|`xscale`     |real          |Horizontal scaling of the occluder's edges, relative to its position                                                                              |
|`yscale`     |real          |Vertical scaling of the occluder's edges, relative to its position                                                                                |
|`angle`      |real          |Rotation of the occluder's edges, relative to its position                                                                                        |
|`vertexArray`|array         |Array of edges, arranged as sequential sets of 4 coordinates (`x1, y1, x2, y2`)                                                                   |
|`bitmask`    |64-bit integer|Which groups to include this occluder in. [BulbMakeBitmask()](GML-Functions#bulbmakebitmaskgroup1-group2-group3-) can be used to generate bitmasks|

The created struct has the following methods (click to expand):

<details><summary><code>.AddEdge(x1, y1, x2, y2)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype      |Purpose                                      |
|----|--------------|---------------------------------------------|
|`x1`|real          |x-coordinate of the first vertex of the edge |
|`y1`|real          |y-coordinate of the first vertex of the edge |
|`x2`|real          |x-coordinate of the second vertex of the edge|
|`y2`|real          |y-coordinate of the second vertex of the edge|

Adds an occlusion edge (a shadow-casting line) to the occluder. For use with [self-lighting](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor), edges should be defined in a **clockwise** order.

&nbsp;
</details>

<details><summary><code>.ClearEdges()</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Removes all edges from the occluder and prepares it for redefinition.

&nbsp;
</details>

<details><summary><code>.AddToRenderer(renderer)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype                                                                   |Purpose                         |
|----------|---------------------------------------------------------------------------|--------------------------------|
|`renderer`|[renderer](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor)|Renderer to add this occluder to|

&nbsp;
</details>

<details><summary><code>.RemoveFromRenderer(renderer)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype                                                                   |Purpose                              |
|----------|---------------------------------------------------------------------------|-------------------------------------|
|`renderer`|[renderer](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor)|Renderer to remove this occluder from|

Manually removing an occluder from a renderer is a relatively slow process and should be avoided where possible.

&nbsp;
</details>

<details><summary><code>.Destroy()</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Instantly destroys the occluder and prevents it from casting shadows.

&nbsp;
</details>