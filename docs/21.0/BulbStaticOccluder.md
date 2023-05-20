### BulbStaticOccluder

&nbsp;

`BulbStaticOccluder(renderer)` ***constructor***

**Constructor returns:** `BulbStaticOccluder` struct

|Name      |Datatype|Purpose                         |
|----------|--------|--------------------------------|
|`renderer`|renderer|Renderer to add this occluder to|

When created, a `BulbStaticOccluder` will be added to the given renderer. An occluder can be added (and removed) from multiple renderers as you see fit.

Static occluders differ from dynamic occluders insofar that their edges, position, rotation, scaling, and group are only updated when either:

1. The renderer performs its very first update
2. [`.RefreshStaticOccluders()`](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor) is called for the renderer.

Static occluders are therefore much more performant than dynamic occluders, but are better suited to use for unmoving objects such as walls and obstacles.

**Please note** that you must maintain a reference to a created `BulbStaticOccluder` yourself. Bulb tracks occluders using a **weak reference** such that when you discard the reference to the occluder, the occluder is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep an occluder alive.

The created struct has the following public member variables:

|Variable     |Datatype|Purpose                                                             |
|-------------|--------|--------------------------------------------------------------------|
|`x`          |number  |x-position of the occluder                                          |
|`y`          |number  |x-position of the occluder                                          |
|`xscale`     |number  |Horizontal scaling of the occluder's edges, relative to its position|
|`yscale`     |number  |Vertical scaling of the occluder's edges, relative to its position  |
|`angle`      |number  |Rotation of the occluder's edges, relative to its position          |

The created struct has the following methods (click to expand):

<details><summary><code>.AddEdge(x1, y1, x2, y2)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose                                      |
|----|--------|---------------------------------------------|
|`x1`|number  |x-coordinate of the first vertex of the edge |
|`y1`|number  |y-coordinate of the first vertex of the edge |
|`x2`|number  |x-coordinate of the second vertex of the edge|
|`y2`|number  |y-coordinate of the second vertex of the edge|

Adds an occlusion edge (a shadow-casting line) to the occluder. Edges should be defined in a **clockwise** order.

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

|Name      |Datatype|Purpose                         |
|----------|--------|--------------------------------|
|`renderer`|renderer|Renderer to add this occluder to|

**Please note** that adding a static occluder will not affect a renderer's output until `.RefreshStaticOccluders()` is called for that renderer.

&nbsp;
</details>

<details><summary><code>.RemoveFromRenderer(renderer)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype|Purpose                              |
|----------|--------|-------------------------------------|
|`renderer`|renderer|Renderer to remove this occluder from|

Manually removing an occluder from a renderer is a relatively slow process and should be avoided where possible.

**Please note** that removing a static occluder will not affect a renderer's output until `.RefreshStaticOccluders()` is called for that renderer.

&nbsp;
</details>

<details><summary><code>.Destroy()</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Destroys the occluder. The occluder will be removed from a renderer the next time you call `.RefreshStaticOccluders()` for that renderer.

&nbsp;
</details>