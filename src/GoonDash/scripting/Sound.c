#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/Sound.h>
#include <SupergoonSound/include/sound.h>

static int BgmLoad(lua_State *L)
{
    // Arg1: String, filename
    // Arg2: float begin loop marker
    // Arg3: float end loop marker
    const char *filename = luaL_checkstring(L, 1);
    float beginLoop = luaL_checknumber(L, 2);
    float endLoop = luaL_checknumber(L, 3);
    Bgm *bgm = LoadBgm(filename, beginLoop, endLoop);
    if (!bgm)
    {
        LogError("Could not load BGM %s", filename);
        lua_pushnil(L);
        return 1;
    }
    int result = PreLoadBgm(bgm);
    // Returns BGM pointer, or nil, which should be free'd afterwards.
    lua_pushlightuserdata(L, bgm);
    return 1;
}

static int SfxLoad(lua_State *L)
{
    // Arg1: String, filename
    const char *filename = luaL_checkstring(L, 1);
    Sfx *sfx = LoadSfxHelper(filename);
    if (!sfx)
    {
        LogError("Could not load Sfx %s", filename);
        lua_pushnil(L);
        return 1;
    }
    int result = LoadSfx(sfx);
    // Returns BGM pointer, or nil, which should be free'd afterwards.
    lua_pushlightuserdata(L, sfx);
    return 1;
}
static int SfxPlay(lua_State *L)
{
    // Arg1: sfx* bgm to play
    // Arg2  number - volume
    if (!lua_islightuserdata(L, 1))
    {
        LogError("Bad argument passed into playsfx, expected a userdata ptr");
        return 0;
    }
    float volume = luaL_checknumber(L, 2);
    Sfx *sfx = (Sfx *)lua_touserdata(L, 1);
    if (!sfx)
    {
        LogError("Pointer passed to playsfx is not able to be casted to a sfx");
        return 0;
    }
    PlaySfxOneShot(sfx, volume);
    return 0;
}

static int BgmPlay(lua_State *L)
{
    // Arg1: Bgm* bgm to play
    // Arg2  number - volume
    if (!lua_islightuserdata(L, 1))
    {
        LogError("Bad argument passed into PlayBGm, expected a userdata ptr");
        return 0;
    }
    float volume = luaL_checknumber(L, 2);
    Bgm *bgm = (Bgm *)lua_touserdata(L, 1);
    if (!bgm)
    {
        LogError("Pointer passed to playbgm is not able to be casted to a bgm");
        return 0;
    }
    PlayBgm(bgm, volume);
    return 0;
}


static int DestroyBgm(lua_State *L)
{
    // Arg1: Bgm*
    if (!lua_islightuserdata(L, 1))
    {
        LogError("Bad argument passed into PlayBGm, expected a userdata ptr");
        return 0;
    }
    Bgm *bgm = (Bgm *)lua_touserdata(L, 1);
    if (!bgm)
    {
        LogError("Pointer passed to playbgm is not able to be casted to a bgm");
        return 0;
    }
    free(bgm);
    return 0;
}

static int luaopen_Sound(lua_State *L)
{
    luaL_newmetatable(L, "Lua.Sound");
    luaL_Reg luaDebugLib[] = {
        {"PlayBgm", BgmPlay},
        {"LoadBgm", BgmLoad},
        {"LoadSfx", SfxLoad},
        {"PlaySfx", SfxPlay},
        {"FreeBgm", DestroyBgm},
        {NULL, NULL} // Sentinel value to indicate the end of the table
    };
    luaL_newlib(L, luaDebugLib);
    return true;
}

int RegisterSoundFunctions(lua_State *L)
{
    luaL_requiref(L, "Sound", luaopen_Sound, 0);
    return true;
}