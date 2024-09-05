# Normal Map Functions

&nbsp;

## BulbNormalMapClear

`BulbNormalMapClear()`

**Returns:** N/A (`undefined`)

|Argument|Datatype|Purpose|
|--------|--------|-------|
|None    |        |       |

Clears a normal map surface, resetting all pixels to "flat" i.e. the normal for that pixel will be set to `(0,0,1)`, a vector that points straight upwards.

&nbsp;

## BulbNormalMapShaderSet

`BulbNormalMapShaderSet([forceFlat=false])`

**Returns:** N/A (`undefined`)

|Argument     |Datatype|Purpose                                                                             |
|-------------|--------|------------------------------------------------------------------------------------|
|`[forceFlat]`|boolean |Whether subsequent draw calls should be forced to draw "flat" data to the normal map|

Before drawing normal map graphics to a renderer's normal map surface using Bulb's native functions (see below) you must call this function. If the `forceFlat` parameter is set to `true` then all draw calls will be forced to "flat" i.e. the normal will be set to `(0,0,1)`, a vector that points straight upwards.

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