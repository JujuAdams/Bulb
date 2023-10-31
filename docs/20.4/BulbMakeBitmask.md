### `BulbMakeBitmask([group1], [group2], [group3], ...)`

**Returns:** 64-bit integer, the bitmask for the given series of boolean flags

|Name      |Datatype|Purpose                                  |
|----------|--------|-----------------------------------------|
|`[group1]`|boolean |Whether to include group 1 in the bitmask|
|`[group2]`|boolean |Whether to include group 2 in the bitmask|
|`[group3]`|boolean |Whether to include group 3 in the bitmask|
|`...`     |boolean |*etc.*                                   |

**Please note** that you may only have up to 64 groups when rendering via [`BulbRendererWithGroups()`](GML-Functions#bulbrendererwithgroupsambientcolour-mode-smooth-maxgroups-constructor) (and [`BulbRenderer()`](GML-Functions#bulbrendererambientcolour-mode-smooth-constructor) doesn't support groups at all).