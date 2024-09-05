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

|Variable       |Datatype|Purpose                                                                              |
|---------------|--------|-------------------------------------------------------------------------------------|
|`ambientColor` |integer |Colour to use for fully shadowed (unlit) areas                                       |
|`mode`         |integer |Rendering mode to use, from the `BULB_MODE` enum (see below)                         |
|`smooth`       |boolean |Whether to render lights with texture filtering on, smoothing out the resulting image|

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

## .GetSurface

`.GetSurface()`

**Returns:** Surface, the lighting surface currently being used by this renderer

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

This function may return `undefined` if no surface exists for the renderer.

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
