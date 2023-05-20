# BulbRenderer

&nbsp;

`BulbRenderer(ambientColour, mode, smooth)` ***constructor***

**Constructor returns:** `BulbRenderer` struct

|Name           |Datatype|Purpose                                                                              |
|---------------|--------|-------------------------------------------------------------------------------------|
|`ambientColour`|integer |Colour to use for fully shadowed (unlit) areas                                       |
|`mode`         |integer |Rendering mode to use, from the `BULB_MODE` enum (see below)                         |
|`smooth`       |boolean |Whether to render lights with texture filtering on, smoothing out the resulting image|

A renderer struct will allocate three vertex buffers and a surface for its use.

**Remember to call the `.Free()` method when discarding a renderer struct otherwise you will create a memory leak.**

**You must free and recreate your renderer when changing rooms.**

The `BULB_MODE` enum contains the following elements:

|Name                       |Functionality                                                                       |
|---------------------------|------------------------------------------------------------------------------------|
|`.HARD_BM_ADD`             |Basic hard shadows with z-buffer stenciling, using the typical `bm_add` blend mode  |
|`.HARD_BM_ADD_SELFLIGHTING`|As above, but allowing occluding objects to be internally lit but still cast shadows|
|`.HARD_BM_MAX`             |As above, but using `bm_max` to reduce bloom                                        |
|`.HARD_BM_MAX_SELFLIGHTING`|As above, but using `bm_max` to reduce bloom                                        |
|`.SOFT_BM_ADD`             |Soft shadows using `bm_add`                                                         |

The created struct has the following public member variables:

|Variable       |Datatype|Purpose                                                                              |
|---------------|--------|-------------------------------------------------------------------------------------|
|`ambientColor` |integer |Colour to use for fully shadowed (unlit) areas                                       |
|`mode`         |integer |Rendering mode to use, from the `BULB_MODE` enum (see below)                         |
|`smooth`       |boolean |Whether to render lights with texture filtering on, smoothing out the resulting image|

The created struct has the following methods (click to expand):

<details><summary><code>.SetAmbientColor(color)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name |Datatype|Purpose                                       |
|-----|--------|----------------------------------------------|
|color|integer |Colour to use for fully shadowed (unlit) areas|

Sets the ambient light colour.

&nbsp;
</details>

<details><summary><code>.GetAmbientColor()</code></summary>
&nbsp;

**Returns:** Integer, the ambient light colour

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

&nbsp;
</details>

<details><summary><code>.Update(viewLeft, viewTop, viewWidth, viewHeight)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype|Purpose                                                  |
|----------|--------|---------------------------------------------------------|
|viewLeft  |number  |x-coordinate of the top-left corner of the rendering area|
|viewTop   |number  |y-coordinate of the top-left corner of the rendering area|
|viewWidth |number  |Width of the rendering area                              |
|viewHeight|number  |Height of the rendering area                             |

Updates the internal lighting/shadow surface for the renderer struct.

&nbsp;
</details>

<details><summary><code>.UpdateFromCamera(camera)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name  |Datatype    |Purpose                                         |
|------|------------|------------------------------------------------|
|camera|camera index|Camera to use to define the light rendering area|

Updates the internal lighting/shadow surface for the renderer struct using the position and dimensions of the provided camera's viewport. Intended to be used alongside `.DrawOnCamera()`.

&nbsp;
</details>

<details><summary><code>.Draw(x, y, [width], [height], [alpha])</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype|Purpose                                                                                                      |
|----------|--------|-------------------------------------------------------------------------------------------------------------|
|`x`       |number  |x-coordinate to draw at                                                                                      |
|`y`       |number  |y-coordinate to draw at                                                                                      |
|`[width]` |number  |Stretched width of the drawn lighting surface. Defaults to no stretching, using the surface's natural width  |
|`[height]`|number  |Stretched height of the drawn lighting surface. Defaults to no stretching, using the surface's natural height|
|`[alpha]` |number  |Alpha blend value to use, with `0.0` being completely invisible. Defaults to `1.0`                           |

Draws the lighting/shadow surface at the given coordinates, and stretched if desired.

&nbsp;
</details>

</details>

<details><summary><code>.DrawOnCamera(camera, [alpha])</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name     |Datatype    |Purpose                                                                           |
|---------|------------|----------------------------------------------------------------------------------|
|camera   |camera index|Camera to use as coordinates to draw the light surface                            |
|`[alpha]`|number      |Alpha blend value to use, with `0.0` being completely invisible. Defaults to `1.0`|

Draws the lighting/shadow surface on the given camera. Intended to be used alongside `.UpdateFromCamera()`.

&nbsp;
</details>

<details><summary><code>.GetSurface()</code></summary>
&nbsp;

**Returns:** Surface, the lighting surface currently being used by this renderer

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This function may return `undefined` if no surface exists for the renderer.

&nbsp;
</details>

<details><summary><code>.RefreshStaticOccluders()</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Refreshes this renderer's static occluders, causing the renderer's output to reflect any changes made to its static occluders.

&nbsp;
</details>

<details><summary><code>.Free()</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Frees memory associated with the renderer struct (vertex buffers and a surface).

&nbsp;
</details>