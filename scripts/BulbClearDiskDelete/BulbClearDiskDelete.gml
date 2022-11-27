function BulbClearDiskDelete()
{
    BulbDiskCacheClose();
    file_delete(__BULB_DISK_CACHE_NAME);
}