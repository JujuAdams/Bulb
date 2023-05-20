### `BulbRendererWithGroups(ambientColour, mode, smooth, maxGroups)` ***constructor***

**Constructor returns:** `BulbRendererWithGroups` struct

|Name           |Datatype|Purpose                                                                              |
|---------------|--------|-------------------------------------------------------------------------------------|
|`ambientColour`|integer |Colour to use for fully shadowed (unlit) areas                                       |
|`mode`         |integer |Rendering mode to use, from the `BULB_MODE` enum (see below)                         |
|`smooth`       |boolean |Whether to render lights with texture filtering on, smoothing out the resulting image|
|`maxGroups`    |integer |The maximum number of groups to consider, between 1 and 64 (inclusive)               |

This function constructs a renderer very similar to [above](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor), and its available methods and variables are the same and behave in the same way.

However, `BulbRendererWithGroups()` controls rendering using groups of occluders instead of treating all lights as being blocked by all occluders. What group each light and occluder is in is controlled by setting their `bitmask` member variable (see below).

**Please note** that there is a moderate performance penalty for rendering using groups. While the maximum possible number of groups is 64, try to use as few groups as possible. If you don't need groups at all or need the best possible performance, please use [`BulbRenderer()`](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor) instead.

Lights and occluders can be in multiple groups at the same time. By default, all lights render occluders from all groups. Additionally, by default, occluders are added in all groups. Please edit `BULB_DEFAULT_LIGHT_BITMASK`, `BULB_DEFAULT_STATIC_BITMASK`, and `BULB_DEFAULT_DYNAMIC_BITMASK` to adjust default group behaviour (found in `__BulbConfig()`).

**Please note** that Bulb will **not** throw an error if a light or occluder is in a group whose index exceeds the maximum number of groups (`maxGroups`), and there is a hard global limit of 64 groups beyond that. Be careful with your group assignments!