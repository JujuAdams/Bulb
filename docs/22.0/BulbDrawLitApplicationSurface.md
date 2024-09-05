# BulbDrawLitApplicationSurface

&nbsp;

`BulbDrawLitApplicationSurface(renderer, [x], [y], [width], [height], [textureFiltering], [alphaBlend=false])`

**Returns:** N/A (`undefined`)

|Argument            |Datatype|Purpose                                                                                                                                |
|--------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------|
|`renderer`          |renderer|Renderer to use to draw the application surface                                                                                        |
|`[x]`               |number  |x position to draw the application surface at. If not specified, the position returned by `application_get_position()` will be used    |
|`[y]`               |number  |y position to draw the application surface at. If not specified, the position returned by `application_get_position()` will be used    |
|`[width]`           |number  |width to draw the application surface. If not specified, the width returned by `application_get_position()` will be used               |
|`[height]`          |number  |heighr to draw the application surface. If not specified, the height returned by `application_get_position()` will be used             |
|`[textureFiltering]`|boolean |Whether to use texture filtering when drawing the application surface. If not specified, the texture filter setting will not be changed|
|`[alphaBlend]`      |boolean |Whether to use texture filtering when drawing the application surface. If not specified, alpha blending will be disabled               |

This function should typically be called in the Post Draw event as a replacement for native automatic drawing or other manual drawing (`draw_surface_stretched(application_surface, ...)` etc.) of the application surface.

?> You'll probably want to call `application_surface_draw_enable(false)` at the start of your game if you're using this function.

!> Do not call this function in a Draw Begin, Draw, or Draw End event. This will end up with the application surface being drawn to itself which will usually cause a rendering error. Instead use the Post Draw event or one of the Draw GUI events.
