# Normal Map Functions

&nbsp;

The functions on this page should be used whilst targeting the normal map surface retrieved from a Bulb renderer with the `.GetNormalMap()` method. The normal map uses a positive Z value (blue channel) to point directly towards the camera such that `#7F7FFF` is a "flat" normal pointing in the direction `(0,0,1)`.

The native `BulbNormalMapDraw*()` functions are optional but recommended. They're set up to utilise a special normal map construction shader. This shader does three important things:

- Calculates normal transformation due to rotation and scaling

- Uses alpha testing to ensure alpha blending don't lead to errors on the normal map

- Effeciently batches draw commands together

Constructing the normal map is a bit of an involved process unfortunately and, outside of the absolutely barebones basics, it's something you'll largely need to handle yourself. Please read this example for further context:

```gml
//First we target the normal map surface
surface_set_target(renderer.GetNormalMapSurface());

//Then we apply the camera. This ensure we're drawing from the same "point of view" as the
//rest of the renderer
camera_apply(renderer.GetCamera());

//Clear off any normal map information from the previous frame
BulbNormalMapClear();

//You don't *have* to use `BulbNormalMapDraw*()` functions!
draw_sprite_tiled(sFloorNormal, 0, 0, 0);

//Set the normal mapping shader. This is required to use the `BulbNormalMapDraw*()` functions
BulbNormalMapShaderSet();

//`BulbNormalMapDrawSelf()` can be used to easily draw normals to match basic objects
with(oPyramid)
{
    BulbNormalMapDrawSelf(sPyramidNormal);
}

//Now we set the normal map shader but this time with `forceUpNormal` set to `true`. This means
//that anything we draw afterwards will be drawn completely flat.
BulbNormalMapShaderSet(true);

with(oDynamicOccluder)
{
    BulbNormalMapDrawSelf();
}

//Reset the surface target and the shader, and we're done
surface_reset_target()
BulbNormalMapShaderReset();
```

&nbsp;

## BulbNormalMapClear

`BulbNormalMapClear()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Clears a normal map surface, resetting all pixels to "flat" i.e. the normal for that pixel will be set to the colour `#7F7FFF` which represents the direction `(0,0,1)`, a vector that points straight upwards.

&nbsp;

## BulbNormalMapShaderSet

`BulbNormalMapShaderSet([forceFlat=false])`

**Returns:** N/A (`undefined`)

|Argument     |Datatype|Purpose                                                                             |
|-------------|--------|------------------------------------------------------------------------------------|
|`[forceFlat]`|boolean |Whether subsequent draw calls should be forced to draw "flat" data to the normal map|

Before drawing normal map graphics to a renderer's normal map surface using Bulb's native functions (see below) you must call this function. If the `forceFlat` parameter is set to `true` then all draw calls will be forced to "flat" i.e. the normal will be set to the colour `#7F7FFF` which represents the direction `(0,0,1)`, a vector that points straight upwards.

When `forceFlat` is set to `false`, this shader does three important things:

- Calculates normal transformation due to rotation and scaling

- Uses alpha testing to ensure alpha blending don't lead to errors on the normal map

- Effeciently batches draw commands together

&nbsp;

## BulbNormalMapShaderReset

`BulbNormalMapShaderReset()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Resets ("un-sets") the Bulb normal map shader.

&nbsp;

## BulbNormalMapDrawSelf

`BulbNormalMapDrawSelf([spriteIndex])`

**Returns:** N/A (`undefined`)

|Argument       |Datatype    |Purpose                                                                                 |
|---------------|------------|----------------------------------------------------------------------------------------|
|`[spriteIndex]`|sprite index|Sprite to draw. If not specified, the instance's current sprite (`sprite_index`) is used|

Analogous to GameMaker's native `draw_self()` function.

?> You should set Bulb's normal map shader before executing this function by calling `BulbNormalMapShaderSet()` beforehand.

&nbsp;

## BulbNormalMapDrawSprite

`BulbNormalMapDrawSprite(sprite, image, x, y)`

**Returns:** N/A (`undefined`)

|Argument|Datatype    |Purpose                         |
|--------|------------|--------------------------------|
|`sprite`|sprite index|Sprite to draw                  |
|`image` |number      |Image of the sprite to draw     |
|`x`     |number      |x position to draw the sprite at|
|`y`     |number      |y position to draw the sprite at|

Analogous to GameMaker's native `draw_sprite()` function.

?> You should set Bulb's normal map shader before executing this function by calling `BulbNormalMapShaderSet()` beforehand.

&nbsp;

## BulbNormalMapDrawSpriteExt

`BulbNormalMapDrawSpriteExt(sprite, image, x, y, xScale, yScale, angle)`

**Returns:** N/A (`undefined`)

|Argument|Datatype    |Purpose                               |
|--------|------------|--------------------------------------|
|`sprite`|sprite index|Sprite to draw                        |
|`image` |number      |Image of the sprite to draw           |
|`x`     |number      |x position to draw the sprite at      |
|`y`     |number      |y position to draw the sprite at      |
|`xScale`|number      |x scale to use when drawing the sprite|
|`yScale`|number      |y scale to use when drawing the sprite|
|`angle` |number      |Rotation of the sprite in degrees     |

Analogous to GameMaker's native `draw_sprite_ext()` function.

?> You should set Bulb's normal map shader before executing this function by calling `BulbNormalMapShaderSet()` beforehand.