# BulbApplyLightingToSurface

&nbsp;

`BulbApplyLightingToSurface(renderer, surface)`

**Returns:** N/A (`undefined`)

|Argument  |Datatype|Purpose                             |
|----------|--------|------------------------------------|
|`renderer`|renderer|Renderer to use to light the surface|
|`surface` |surface |Surface to affect with lighting     |

Applies a Bulb renderer's lighting directly to a surface. Typically, this would be `application_surface`.

Bulb uses gamma correct lighting and, as such, works in a slightly different way to most other GameMaker lighting systems. Instead of multiplying the light on top of a source surface (typically the application surface), Bulb instead combines the source surface with the lighting in a special shader called a "tonemapping" shader. This process is complex, especially for HDR lighting and bloom, so it is wrapped up inside this helper function.

!> This function is substantially slower than the preferred `BulbDrawLitSurface()` function. It is provided as an easier alternative to apply lighting without having to reprogram other parts of your rendering pipeline. If you are concerned about performance, you should swap to using `BulbDrawLitSurface()`.