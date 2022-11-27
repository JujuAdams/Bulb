function BulbDiskCacheClose()
{
    if (global.__bulbCacheBuffer != undefined)
    {
        buffer_delete(global.__bulbCacheBuffer);
        
        global.__bulbCacheBuffer = undefined;
        global.__bulbCacheDict   = {};
        
        __BulbTrace("Disk cache closed");
    }
    else
    {
        __BulbTrace("Disk cache already closed");
    }
}