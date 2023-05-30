function __BulbGlobal()
{
    static _struct = {
        __vFormatHard: undefined,
        __vFormatSoft: undefined,
        
        __spriteDict:  {},
        __tilesetDict: {},
        
        __projectDirectory: undefined,
        __cacheBuffer:      undefined,
        __cacheDict:        {},
        __cachePauseSave:   false,
    };
    
    return _struct;
}