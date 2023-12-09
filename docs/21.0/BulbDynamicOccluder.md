# BulbDynamicOccluder

&nbsp;

`BulbDynamicOccluder(renderer)` ***constructor***

**Constructor returns:** `BulbDynamicOccluder` struct

|Argument  |Datatype|Purpose                         |
|----------|--------|--------------------------------|
|`renderer`|renderer|Renderer to add this occluder to|

When created, a `BulbDynamicOccluder` will be added to the given renderer. An occluder can be added (and removed) from multiple renderers as you see fit.

When dynamic occluders are drawn is controlled, in part, by `BULB_DYNAMIC_OCCLUDER_RANGE` found in `__BulbConfig()`. If you have large dynamic occluders and you're experiencing pop-in, increase this value.

?> You must maintain a reference to a created `BulbDynamicOccluder` yourself. Bulb tracks occluders using a **weak reference** such that when you discard the reference to the occluder, the occluder is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep an occluder alive.

&nbsp;

## Member Variables

The created struct has the following public member variables:

|Variable     |Datatype      |Purpose                                                                        |
|-------------|--------------|-------------------------------------------------------------------------------|
|`visible`    |boolean       |Whether to draw the occluder at all                                            |
|`x`          |number        |x-position of the occluder                                                     |
|`y`          |number        |x-position of the occluder                                                     |
|`xscale`     |number        |Horizontal scaling of the occluder's edges, relative to its position           |
|`yscale`     |number        |Vertical scaling of the occluder's edges, relative to its position             |
|`angle`      |number        |Rotation of the occluder's edges, relative to its position                     |
|`vertexArray`|array         |Array of edges, arranged as sequential sets of 4 coordinates (`x1, y1, x2, y2`)|

&nbsp;

## .AddEdge

`.AddEdge(x1, y1, x2, y2)`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose                                      |
|--------|--------|---------------------------------------------|
|`x1`    |number  |x-coordinate of the first vertex of the edge |
|`y1`    |number  |y-coordinate of the first vertex of the edge |
|`x2`    |number  |x-coordinate of the second vertex of the edge|
|`y2`    |number  |y-coordinate of the second vertex of the edge|

Adds an occlusion edge (a shadow-casting line) to the occluder. Edges should be defined in a **clockwise** order.

&nbsp;

## .ClearEdges

`.ClearEdges()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Removes all edges from the occluder and prepares it for redefinition.

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

|Argument  |Datatype|Purpose                              |
|----------|--------|-------------------------------------|
|`renderer`|renderer|Renderer to remove this occluder from|

Manually removing an occluder from a renderer is a relatively slow process and should be avoided where possible.

&nbsp;

## .Destroy

`.Destroy()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |