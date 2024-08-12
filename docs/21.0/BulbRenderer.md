# BulbRenderer

&nbsp;

`BulbRenderer(ambientColour, mode, smooth)` ***constructor***

**Constructor returns:** `BulbRenderer` struct

|Argument       |Datatype|Purpose                                                                              |
|---------------|--------|-------------------------------------------------------------------------------------|
|`ambientColour`|integer |Colour to use for fully shadowed (unlit) areas                                       |
|`mode`         |integer |Rendering mode to use, from the `BULB_MODE` enum (see below)                         |
|`smooth`       |boolean |Whether to render lights with texture filtering on, smoothing out the resulting image|

Setting the `smooth` argument to `true` will turn on bilinear texture filtering when calling `.Draw()` and `.DrawOnCamera()`. This may result in light bleed if you're using a low resolution camera or have set a low resolution surface size with `.SetSurfaceDimensions()`. This is especially noticeable with self-lighting rendering modes. Typically you wil want to set `smooth` to `false` for low resolution lighting as a result.

!> A renderer struct will allocate vertex buffers and surfaces for its use. Remember to call the `.Free()` method when discarding a renderer struct otherwise you will create a memory leak.

!> You must free and recreate your renderer when changing rooms.

&nbsp;

## BULB_MODE enum

|Argument                   |Functionality                                                                       |
|---------------------------|------------------------------------------------------------------------------------|
|`.HARD_BM_ADD`             |Basic hard shadows with z-buffer stenciling, using the typical `bm_add` blend mode  |
|`.HARD_BM_ADD_SELFLIGHTING`|As above, but allowing occluding objects to be internally lit but still cast shadows|
|`.HARD_BM_MAX`             |As above, but using `bm_max` to reduce bloom                                        |
|`.HARD_BM_MAX_SELFLIGHTING`|As above, but using `bm_max` to reduce bloom                                        |
|`.SOFT_BM_ADD`             |Soft shadows using `bm_add`                                                         |

!> `BULB_MODE.SOFT_BM_ADD` uses up a lot of GPU bandwidth. Lower-end GPUs may become saturated and struggle to keep a consistent framerate. Make sure to test thoroughly and offer graphics options if you're using this rendering mode.

&nbsp;

## Member Variables

The created struct has the following public member variables:

|Variable       |Datatype|Purpose                                                                                                                                                                   |
|---------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|`ambientColor` |integer |Colour to use for fully shadowed (unlit) areas                                                                                                                            |
|`mode`         |integer |Rendering mode to use, from the `BULB_MODE` enum (see below)                                                                                                              |
|`smooth`       |boolean |Whether to render lights with texture filtering on, smoothing out the resulting image                                                                                     |
|`surfaceWidth` |real    |Width of the output surface. If set to a negative number, this value will automatically be replaced with the size of the rendering area when the renderer is next updated |
|`surfaceHeight`|real    |Height of the output surface. If set to a negative number, this value will automatically be replaced with the size of the rendering area when the renderer is next updated|

&nbsp;

## .Update

`.Update(viewLeft, viewTop, viewWidth, viewHeight)`

**Returns:** N/A (`undefined`)

|Argument  |Datatype|Purpose                                                  |
|----------|--------|---------------------------------------------------------|
|viewLeft  |number  |x-coordinate of the top-left corner of the rendering area|
|viewTop   |number  |y-coordinate of the top-left corner of the rendering area|
|viewWidth |number  |Width of the rendering area                              |
|viewHeight|number  |Height of the rendering area                             |

Updates the internal lighting/shadow surface for the renderer struct.

&nbsp;

## .UpdateFromCamera

`.UpdateFromCamera(camera)`

**Returns:** N/A (`undefined`)

|Argument|Datatype    |Purpose                                         |
|--------|------------|------------------------------------------------|
|camera  |camera index|Camera to use to define the light rendering area|

Updates the internal lighting/shadow surface for the renderer struct using the position and dimensions of the provided camera's viewport. Intended to be used alongside `.DrawOnCamera()`.

&nbsp;

## .Draw

`.Draw(x, y, [width], [height], [alpha])`

**Returns:** N/A (`undefined`)

|Argument  |Datatype|Purpose                                                                                                      |
|----------|--------|-------------------------------------------------------------------------------------------------------------|
|`x`       |number  |x-coordinate to draw at                                                                                      |
|`y`       |number  |y-coordinate to draw at                                                                                      |
|`[width]` |number  |Stretched width of the drawn lighting surface. Defaults to no stretching, using the surface's natural width  |
|`[height]`|number  |Stretched height of the drawn lighting surface. Defaults to no stretching, using the surface's natural height|
|`[alpha]` |number  |Alpha blend value to use, with `0.0` being completely invisible. Defaults to `1.0`                           |

Draws the lighting/shadow surface at the given coordinates, and stretched if desired.

&nbsp;

## .DrawOnCamera

`.DrawOnCamera(camera, [alpha])`

**Returns:** N/A (`undefined`)

|Argument |Datatype    |Purpose                                                                           |
|---------|------------|----------------------------------------------------------------------------------|
|camera   |camera index|Camera to use as coordinates to draw the light surface                            |
|`[alpha]`|number      |Alpha blend value to use, with `0.0` being completely invisible. Defaults to `1.0`|

Draws the lighting/shadow surface on the given camera. Intended to be used alongside `.UpdateFromCamera()`.

&nbsp;

## .RefreshStaticOccluders

`.RefreshStaticOccluders()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Refreshes this renderer's static occluders, causing the renderer's output to reflect any changes made to its static occluders.

&nbsp;

## .Free

`.Free()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Frees memory associated with the renderer struct (vertex buffers and a surface).

&nbsp;

## .SetAmbientColor

`.SetAmbientColor(color)`

**Returns:** N/A (`undefined`)

|Name |Datatype|Purpose                                       |
|-----|--------|----------------------------------------------|
|color|integer |Colour to use for fully shadowed (unlit) areas|

Sets the ambient light colour.

&nbsp;

## .GetAmbientColor

`.GetAmbientColor()`

**Returns:** Integer, the ambient light colour

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

&nbsp;

## .GetSurface

`.GetSurface()`

**Returns:** Surface, the lighting surface currently being used by this renderer

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

This function may return `undefined` if no surface exists for the renderer.

&nbsp;

## .SetSurfaceDimensions

`.SetSurfaceDimensions(width, height)`

**Returns:** N/A (`undefined`)

|Name  |Datatype|Purpose                         |
|------|--------|--------------------------------|
|width |integer |Width of the surface, in pixels |
|height|integer |Height of the surface, in pixels|

Sets the size of the light surface and clipping surface to the provided width and height.

?> This function is optional and is provided to force a surface resolution for e.g. improving performance by reducing lighting accuracy.

&nbsp;

## .GetSurfacePixel

`.GetSurfacePixel(worldX, worldY, viewLeft, viewTop, viewWidth, viewHeight)`

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

## .GetSurfacePixelFromCamera

`.GetSurfacePixelFromCamera(worldX, worldY, camera)`

**Returns:** Colour, the colour of the lighting at the position in world space

|Name  |Datatype|Purpose                               |
|------|--------|--------------------------------------|
|worldX|real    |x-coordinate of the position to sample|
|worldY|real    |y-coordinate of the position to sample|
|camera|[camera index](https://docs2.yoyogames.com/source/_build/3_scripting/4_gml_reference/cameras%20and%20display/cameras/index.html)|Camera to use to define the light rendering area|

If you sample a colour outside the view, this function will return black (`0`).

!> This function is quite slow. Use it sparingly.

&nbsp;

## .SetClippingSurface

`.SetClippingSurface(clipisShadow, clipAlpha, clipInvert, hsvValueToAlpha)`

**Returns:** N/A (`undefined`)

|Name               |Datatype|Purpose|
|-------------------|--------|-------|
|clipisShadow       |boolean |Whether the clipped areas should be rendered as shadow. Setting this to value will adjust the alpha value of clipped pixels instead|
|clipAlpha          |number  |The strength of the clipping effect. A value of `0` will perform no clipping, a value of `1` will maximise clipping|
|\[clipInvert\]     |boolean |Whether to invert clipping such that high alpha areas remove light. Defaults to `false`|
|\[hsvValueToAlpha\]|boolean |Whether to use the HSV value component as the masking factor. Defaults to `false`      |

&nbsp;

## .SetClippingSurface

`.GetClippingSurface()`

**Returns:** Surface, the clipping surface currently being used by this renderer

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

This function may return `undefined` if no clipping surface exists for the renderer.

&nbsp;

## .CopyClippingSurface

`.CopyClippingSurface(surface)`

**Returns:** N/A (`undefined`)

|Name   |Datatype|Purpose                               |
|-------|--------|--------------------------------------|
|surface|surface |Surface to copy the clipping data from|

&nbsp;

## .RemoveClippingSurface

`.RemoveClippingSurface()`

**Returns:** N/A (`undefined`)

|Name|Datatype|Purpose|
|----|--------|-------|
|None|        |       |

Removes the clipping surface from the renderer.
