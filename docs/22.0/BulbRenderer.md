# BulbRenderer

&nbsp;

`BulbRenderer([camera])` ***constructor***

**Constructor returns:** `BulbRenderer` struct

|Argument  |Datatype|Purpose                                                                                                                      |
|----------|--------|-----------------------------------------------------------------------------------------------------------------------------|
|`[camera]`|camera  |Camera to use as the point of view for light rendering. If not specified, the renderer will attempt to render the entire room|

A renderer struct is a container for lots of variables and methods that enable the rendering of lights. By itself, a renderer won't do anything. There are a few hoops to jump through first:

- You must add lights and occluders to a renderer for lights and shadows to appear (see `BulbLight()`, `BulbSunlight()`, `BulbDynamicOccluder()`, and `BulbStaticOccluder()`)

- You must call the `.Update()` method on a renderer to update its internal lighting surface

- You must call the `BulbDrawLitApplicationSurface()` function (or the `.DrawLitSurface()` method) to allow a renderer to affect your game

Whilst I've tried to keep the process as simple as possible, there are a lot of steps to getting a renderer set up in your project. The [Quick Start](Quick-Start) guide makes a basic implementation as smooth as possible.

!> A renderer struct will allocate vertex buffers and surfaces for its use. Remember to call the `.Free()` method when discarding a renderer struct otherwise you will create a memory leak. You must free and recreate your renderer when changing rooms.

&nbsp;

## Member Variables

The created struct has the following public member variables. These may be set as needed.

|Variable              |Datatype|Typical Value       |Purpose                                                                                      |
|----------------------|--------|--------------------|---------------------------------------------------------------------------------------------|
|`.ambientColor`       |color   |`c_black`           |Baseline ambient light color                                                                 |
|`.ambientInGammaSpace`|boolean |`false`             |Whether the above is in gamma space (`true`) or linear space {`false`)                       |
|`.smooth`             |boolean |`true`              |Whether to use texture filtering (bilinear interpolation) where possible                     |
|`.soft`               |boolean |`true`              |Whether to use soft shadows                                                                  |
|`.selfLighting`       |boolean |`false`             |Whether to allow light to enter but not escape occluders. Supported in hard shadow mode only |
|`.exposure`           |number  |`1.0`               |Exposure for the entire lighting render. Should usually be left at `1.0` when not in HDR mode|
|`.ldrTonemap`         |constant|`BULB_TONEMAP_CLAMP`|Tonemap to use when not in HDR mode. Should usually be left at `BULB_TONEMAP_CLAMP`          |
|`.hdr`                |boolean |`false`             |Whether to use HDR rendering or not. HDR surface is 16-bit                                   |
|`.hdrTonemap`         |constant|`BULB_TONEMAP_HBD`  |Tonemap to use when in HDR mode                                                              |
|`.hdrBloomIntensity`  |number  |`0`                 |Intensity of the bloom effect                                                                |
|`.hdrBloomIterations` |number  |`3`                 |Number of Kawase blur iterations to apply to the bloom                                       |
|`.hdrBloomThesholdMin`|number  |`0.6`               |Lower threshold for bloom cut-off                                                            |
|`.hdrBloomThesholdMax`|number  |`0.8`               |Upper threshold for bloom cut-off                                                            |
|`.normalMap`          |boolean |Config macro        |Whether normal mapping should be used. Defaults to `BULB_DEFAULT_USE_NORMAL_MAP`             |

&nbsp;

## .Free

`.Free()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Frees memory associated with the renderer struct (vertex buffers and a surface).

&nbsp;

## .SetCamera

`.SetCamera(camera)`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|`camera`|camera  |Camera to use as the point of view for light rendering. If `undefined` is used as the camera, then renderer will attempt to render the entire room|

&nbsp;

## .GetCamera

`.GetCamera()`

**Returns:** Camera, the camera being used as the point of view for light rendering

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

This function will always return a valid camera. If the renderer was instantiated with no camera or `.SetCamera()` was called using `undefined` as the camera, this function will return a camera that encompasses the entire room.

&nbsp;

## .Update

`.Update()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Updates the internal lighting/shadow surface for the renderer struct.

&nbsp;

## .DrawLitSurface

`.DrawLitSurface(surface, x, y, width, height, [textureFiltering], [alphaBlend])`

**Returns:** N/A (`undefined`)

|Argument            |Datatype|Purpose                                                                                                                                |
|--------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------|
|`surface`           |surface |Surface to draw with lighting                                                                                                          |
|`x`                 |number  |x-coordinate to draw at                                                                                                                |
|`y`                 |number  |y-coordinate to draw at                                                                                                                |
|`width`             |number  |Stretched width of the drawn lighting surface                                                                                          |
|`height`            |number  |Stretched height of the drawn lighting surface                                                                                         |
|`[textureFiltering]`|boolean |Whether to use texture filtering when drawing the application surface. If not specified, the texture filter setting will not be changed|
|`[alphaBlend]`      |boolean |Whether to use texture filtering when drawing the application surface. If not specified, the alpha blending setting will not be changed|

Draws a surface, lit up by the renderer. The surface will be appropriately gamma corrected, tonemapped, and bloomed as per the renderer's settings.

!> Be careful not to draw a lit surface to itself! This can cause serious rendering errors. If you'd like to draw the application surface, please see `BulbDrawLitApplicationSurface()`.

&nbsp;

## .RefreshStaticOccluders

`.RefreshStaticOccluders()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Refreshes this renderer's static occluders, causing the renderer's output to reflect any changes made to its static occluders.

&nbsp;

## .SetSurfaceDimensions

`.SetSurfaceDimensions(width, height)`

**Returns:** N/A (`undefined`)

|Name  |Datatype|Purpose                         |
|------|--------|--------------------------------|
|width |integer |Width of the surface, in pixels |
|height|integer |Height of the surface, in pixels|

Sets the size of the light surface to the provided width and height.

?> This function is optional and is provided to force a surface resolution for e.g. improving performance by reducing lighting accuracy.

&nbsp;

## .GetSurfaceDimensions

`.SetSurfaceDimensions()`

**Returns:** Struct, a two-element struct containing the width and height of the lighting surface

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

The struct that this function returns is static. It contains two variables: `.width` and `.height`.

&nbsp;

## .GetTonemap

`.GetTonemap()`

**Returns:** One of the `BULB_TONEMAP_*` values

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Returns the current tonemap. If in HDR mode this will return `.hdrTonemap`, otherwise this function will return `.ldrTonemap`.

&nbsp;

## .GetLightSurface

`.GetLightSurface()`

**Returns:** Surface, the lighting surface currently being used by this renderer

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

This function may return `undefined` if no surface exists for the renderer.

&nbsp;

## .GetLightValue

`.GetLightValue(worldX, worldY)`

**Returns:** Colour, the colour of the lighting at the position in world space

|Name  |Datatype|Purpose                               |
|------|--------|--------------------------------------|
|worldX|number  |x-coordinate of the position to sample|
|worldY|number  |y-coordinate of the position to sample|

If you sample a colour outside the view, this function will return black (`0`). The colour will be gamma corrected depending on what tonemap you have set.

!> This function is very slow. Use it sparingly.

&nbsp;

## .GetNormalMapSurface

`.GetNormalMapSurface()`

**Returns:** Surface, the normal map surface currently being used by this renderer

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

This function may return `undefined` if no normal map surface exists for the renderer.

&nbsp;

## .DrawNormalMapDebug

`.DrawNormalMapDebug(x, y, width, height)`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose                          |
|--------|--------|---------------------------------|
|`x`     |number  |x position to draw the surface at|
|`y`     |number  |y position to draw the surface at|
|`width` |number  |Width of the surface when drawn  |
|`height`|number  |Height of the surface when drawn |

Convenience function to draw the normal map surface. Useful for sanity checking normal maps.
