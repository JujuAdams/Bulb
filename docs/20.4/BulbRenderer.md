### `BulbRenderer(ambientColour, mode, smooth)` ***constructor***

**Constructor returns:** `BulbRenderer` struct

|Name           |Datatype|Purpose                                                                              |
|---------------|--------|-------------------------------------------------------------------------------------|
|`ambientColour`|integer |Colour to use for fully shadowed (unlit) areas                                       |
|`mode`         |integer |Rendering mode to use, from the `BULB_MODE` enum (see below)                         |
|`smooth`       |boolean |Whether to render lights with texture filtering on, smoothing out the resulting image|

A renderer struct will allocate three vertex buffers and a surface for its use.

!> Remember to call the `.Free()` method when discarding a renderer struct otherwise you will create a memory leak. You must free and recreate your renderer when changing rooms.

The `BULB_MODE` enum contains the following elements:

|Name                       |Functionality                                                                       |
|---------------------------|------------------------------------------------------------------------------------|
|`.HARD_BM_ADD`             |Basic hard shadows with z-buffer stenciling, using the typical `bm_add` blend mode  |
|`.HARD_BM_ADD_SELFLIGHTING`|As above, but allowing occluding objects to be internally lit but still cast shadows|
|`.HARD_BM_MAX`             |As above, but using `bm_max` to reduce bloom                                        |
|`.HARD_BM_MAX_SELFLIGHTING`|As above, but using `bm_max` to reduce bloom                                        |
|`.SOFT_BM_ADD`             |Soft shadows using `bm_add`                                                         |

The created struct has the following public member variables:

|Variable       |Datatype|Purpose                                                                                                                                                                   |
|---------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`ambientColor` |integer |Colour to use for fully shadowed (unlit) areas                                                                                                                            |
|`mode`         |integer |Rendering mode to use, from the `BULB_MODE` enum (see below)                                                                                                              |
|`smooth`       |boolean |Whether to render lights with texture filtering on, smoothing out the resulting image                                                                                     |
|`surfaceWidth` |real    |Width of the output surface. If set to a negative number, this value will automatically be replaced with the size of the rendering area when the renderer is next updated |
|`surfaceHeight`|real    |Height of the output surface. If set to a negative number, this value will automatically be replaced with the size of the rendering area when the renderer is next updated|

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

<details><summary><code>.SetSurfaceDimensions(width, height)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name  |Datatype|Purpose                         |
|------|--------|--------------------------------|
|width |integer |Width of the surface, in pixels |
|height|integer |Height of the surface, in pixels|

Sets the size of the light surface and clipping surface to the provided width and height.

?> This function is optional and is provided to force a surface resolution for e.g. improving performance by reducing lighting accuracy.

&nbsp;
</details>

<details><summary><code>.SetSurfaceDimensionsFromCamera(camera)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|camera|[camera index](https://docs2.yoyogames.com/source/_build/3_scripting/4_gml_reference/cameras%20and%20display/cameras/index.html)|Camera to use to define the surface dimensions|

Sets the size of the light surface and clipping surface to the dimensions of the specified camera.

?> This function is optional and is provided to force a surface resolution.

&nbsp;
</details>

<details><summary><code>.Update(viewLeft, viewTop, viewWidth, viewHeight)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype|Purpose                                                  |
|----------|--------|---------------------------------------------------------|
|viewLeft  |real    |x-coordinate of the top-left corner of the rendering area|
|viewTop   |real    |y-coordinate of the top-left corner of the rendering area|
|viewWidth |real    |Width of the rendering area                              |
|viewHeight|real    |Height of the rendering area                             |

Updates the internal lighting/shadow surface for the renderer struct.

&nbsp;
</details>

<details><summary><code>.UpdateFromCamera(camera)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|camera|[camera index](https://docs2.yoyogames.com/source/_build/3_scripting/4_gml_reference/cameras%20and%20display/cameras/index.html)|Camera to use to define the light rendering area|

Updates the internal lighting/shadow surface for the renderer struct using the position and dimensions of the provided camera's viewport. Intended to be used alongside `.DrawOnCamera()`.

&nbsp;
</details>

<details><summary><code>.Draw(x, y, [width], [height], [alpha])</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name      |Datatype|Purpose                                                                                                      |
|----------|--------|-------------------------------------------------------------------------------------------------------------|
|`x`       |real    |x-coordinate to draw at                                                                                      |
|`y`       |real    |y-coordinate to draw at                                                                                      |
|`[width]` |real    |Stretched width of the drawn lighting surface. Defaults to no stretching, using the surface's natural width  |
|`[height]`|real    |Stretched height of the drawn lighting surface. Defaults to no stretching, using the surface's natural height|
|`[alpha]` |real    |Alpha blend value to use, with `0.0` being completely invisible. Defaults to `1.0`                           |

Draws the lighting/shadow surface at the given coordinates, and stretched if desired.

&nbsp;
</details>

</details>

<details><summary><code>.DrawOnCamera(camera, [alpha])</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name     |Datatype|Purpose                                                                           |
|---------|--------|----------------------------------------------------------------------------------|
|camera   |[camera index](https://docs2.yoyogames.com/source/_build/3_scripting/4_gml_reference/cameras%20and%20display/cameras/index.html)|Camera to use as coordinates to draw the light surface|
|`[alpha]`|real    |Alpha blend value to use, with `0.0` being completely invisible. Defaults to `1.0`|

Draws the lighting/shadow surface on the given camera. Intended to be used alongside `.UpdateFromCamera()`.

&nbsp;
</details>

<details><summary><code>.RefreshStaticOccluders()</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Refreshes this renderer's [static occluders](GML-Functions#bulbstaticoccluderrenderer-constructor), causing the renderer's output to reflect any changes made to its static occluders.

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

<details><summary><code>.GetSurface()</code></summary>
&nbsp;

**Returns:** Surface, the lighting surface currently being used by this renderer

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This function may return `undefined` if no surface exists for the renderer.

&nbsp;
</details>

<details><summary><code>.GetSurfacePixel(worldX, worldY, viewLeft, viewTop, viewWidth, viewHeight)</code></summary>
&nbsp;

**Returns:** Colour, the colour of the lighting at the position in world space

|Name      |Datatype|Purpose                                                  |
|----------|--------|---------------------------------------------------------|
|worldX    |real    |x-coordinate of the position to sample                   |
|worldY    |real    |y-coordinate of the position to sample                   |
|viewLeft  |real    |x-coordinate of the top-left corner of the rendering area|
|viewTop   |real    |y-coordinate of the top-left corner of the rendering area|
|viewWidth |real    |Width of the rendering area                              |
|viewHeight|real    |Height of the rendering area                             |

If you sample a colour outside the view, this function will return black (`0`).

!> This function is quite slow. Use it sparingly.

&nbsp;
</details>

<details><summary><code>.GetSurfacePixelFromCamera(worldX, worldY, camera)</code></summary>
&nbsp;

**Returns:** Colour, the colour of the lighting at the position in world space

|Name  |Datatype|Purpose                               |
|------|--------|--------------------------------------|
|worldX|real    |x-coordinate of the position to sample|
|worldY|real    |y-coordinate of the position to sample|
|camera|[camera index](https://docs2.yoyogames.com/source/_build/3_scripting/4_gml_reference/cameras%20and%20display/cameras/index.html)|Camera to use to define the light rendering area|

If you sample a colour outside the view, this function will return black (`0`).

!> This function is quite slow. Use it sparingly.

&nbsp;
</details>

<details><summary><code>.SetClippingSurface(clipisShadow, clipAlpha, clipInvert, hsvValueToAlpha)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name               |Datatype|Purpose|
|-------------------|--------|-------|
|clipisShadow       |boolean |Whether the clipped areas should be rendered as shadow. Setting this to value will adjust the alpha value of clipped pixels instead|
|clipAlpha          |number  |The strength of the clipping effect. A value of `0` will perform no clipping, a value of `1` will maximise clipping|
|\[clipInvert\]     |boolean |Whether to invert clipping such that high alpha areas remove light. Defaults to `false`|
|\[hsvValueToAlpha\]|boolean |Whether to use the HSV value component as the masking factor. Defaults to `false`      |

&nbsp;
</details>

<details><summary><code>.GetClippingSurface()</code></summary>
&nbsp;

**Returns:** Surface, the clipping surface currently being used by this renderer

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This function may return `undefined` if no clipping surface exists for the renderer.

&nbsp;
</details>

<details><summary><code>.CopyClippingSurface(surface)</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name   |Datatype|Purpose                               |
|-------|--------|--------------------------------------|
|surface|surface |Surface to copy the clipping data from|

&nbsp;
</details>

<details><summary><code>.RemoveClippingSurface()</code></summary>
&nbsp;

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Removes the clipping surface from the renderer.

&nbsp;
</details>
