#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/Physics.h>
#include <GoonDash/scripting/SdlRect.h>
#include <GoonPhysics/GoonPhysics.h>

static int AddBodyToScene(lua_State *L)
{
    // Arg1: SdlRect For Body
    // Return1: Body integer for lookup.
    SDL_Rect bodySdlRect = GetRectFromLuaTable(L, 1);
    gpBB bb = gpBBNew(bodySdlRect.x, bodySdlRect.y, bodySdlRect.w, bodySdlRect.h);
    gpBody *body = gpBodyNew(bb);
    int bodyNum = gpSceneAddBody(body);
    lua_pushinteger(L, bodyNum);
    return 1;
}

static int GetBodyCoordinates(lua_State *L)
{
    // Arg1: Body num
    // Return1: x
    // Return2: y
    int bodyRef = luaL_checkinteger(L, 1);
    gpBody* body = gpSceneGetBody(bodyRef);
    if(!body)
    {
        LogWarn("Could not get body num %d from the physics scene", bodyRef);
        lua_pushnil(L);
        return 1;
    }
    lua_pushnumber(L, body->boundingBox.x);
    lua_pushnumber(L, body->boundingBox.y);
    return 2;
}

static int luaopen_GoonPhysics(lua_State *L)
{
    luaL_newmetatable(L, "Lua.Physics");
    luaL_Reg luaPhysicsLib[] = {
        {"AddBody", AddBodyToScene},
        {"GetBodyLocation", GetBodyCoordinates},
        {NULL, NULL} // Sentinel value to indicate the end of the table
    };
    luaL_newlib(L, luaPhysicsLib);
    return true;
}

int RegisterPhysicsFunctions(lua_State *L)
{
    luaL_requiref(L, "GoonPhysics", luaopen_GoonPhysics, 0);
    return true;
}