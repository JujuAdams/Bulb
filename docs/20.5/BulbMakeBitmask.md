# BulbMakeBitmask

&nbsp;

`BulbMakeBitmask([group1], [group2], [group3], ...)`

**Returns:** 64-bit integer, the bitmask for the given series of boolean flags

|Name      |Datatype|Purpose                                  |
|----------|--------|-----------------------------------------|
|`[group1]`|boolean |Whether to include group 1 in the bitmask|
|`[group2]`|boolean |Whether to include group 2 in the bitmask|
|`[group3]`|boolean |Whether to include group 3 in the bitmask|
|`...`     |boolean |*etc.*                                   |

You may only have up to 64 groups when rendering via `BulbRendererWithGroups()` (and `BulbRenderer()` doesn't support groups at all).