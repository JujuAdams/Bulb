# BulbStaticOccluder

&nbsp;

`BulbStaticOccluder(renderer)` ***constructor***

**Constructor returns:** `BulbStaticOccluder` struct

|Argument  |Datatype|Purpose                         |
|----------|--------|--------------------------------|
|`renderer`|renderer|Renderer to add this occluder to|

When created, a `BulbStaticOccluder` will be added to the given renderer. An occluder can be added (and removed) from multiple renderers as you see fit.

Static occluders differ from dynamic occluders insofar that their edges, position, rotation, and scaling are only updated when either:

1. The renderer performs its very first update
2. `.RefreshStaticOccluders()` is called for the renderer.

Static occluders are therefore much more performant than dynamic occluders, but are better suited to use for unmoving objects such as walls and obstacles.

?> You must maintain a reference to a created `BulbStaticOccluder` yourself. Bulb tracks occluders using a **weak reference** such that when you discard the reference to the occluder, the occluder is also automatically removed from the renderer. This makes memory management a lot safer, but does require that you keep your own strong reference to keep an occluder alive.

&nbsp;

## Member Variables

The created struct has the following public member variables:

|Variable     |Datatype      |Purpose                                                                        |
|-------------|--------------|-------------------------------------------------------------------------------|
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

## .AddCircle

`.AddEdge(radius, [x=0], [y=0], [edges=24])`

**Returns:** N/A (`undefined`)

|Argument |Datatype|Purpose                                                   |
|---------|--------|----------------------------------------------------------|
|`radius` |number  |Radius of the circle to add to the occluder               |
|`[x]`    |number  |x-coordinate of the centre of the circle. Defaults to `0` |     
|`[y]`    |number  |y-coordinate of the centre of the circle. Defaults to `0` |     
|`[edges]`|number  |Number of edges to create for the circle. Defaults to `24`|

Helper function to add a circle to the occluder. The circle will be made of multiple individual straight edges.

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

?> Adding a static occluder will not affect a renderer's output until `.RefreshStaticOccluders()` is called for that renderer.

&nbsp;

## .RemoveFromRenderer

`.RemoveFromRenderer(renderer)`

**Returns:** N/A (`undefined`)

|Argument  |Datatype|Purpose                              |
|----------|--------|-------------------------------------|
|`renderer`|renderer|Renderer to remove this occluder from|

Manually removing an occluder from a renderer is a relatively slow process and should be avoided where possible.

?> Removing a static occluder will not affect a renderer's output until `.RefreshStaticOccluders()` is called for that renderer.

&nbsp;

## .Destroy

`.Destroy()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

?> Destroying a static occluder will not affect a renderer's output until `.RefreshStaticOccluders()` is called for that renderer.