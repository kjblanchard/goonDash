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

static int AddStaticBodyToScene(lua_State *L)
{
    // Arg1: SdlRect For Body
    // Return1: Body integer for lookup.
    SDL_Rect bodySdlRect = GetRectFromLuaTable(L, 1);
    gpBB bb = gpBBNew(bodySdlRect.x, bodySdlRect.y, bodySdlRect.w, bodySdlRect.h);
    gpBody *body = gpBodyNew(bb);
    int bodyNum = gpSceneAddStaticBody(body);
    lua_pushinteger(L, bodyNum);
    return 1;
}

static int AddForceToBody(lua_State *L)
{
    // Arg1: Body num
    // Arg2: Force X
    // Arg3: Force Y
    int bodyNum = luaL_checkinteger(L, 1);
    float forceX = luaL_checknumber(L, 2);
    float forceY = luaL_checknumber(L, 3);
    gpBody* body = gpSceneGetBody(bodyNum);
    if(!body)
    {
        return 0;
    }
    body->velocity.x += forceX;
    body->velocity.y += forceY;
    return 0;
}

static int IsBodyOnGround(lua_State *L)
{
    // Arg1: Body num
    // Return1: is on ground bool
    int bodyNum = luaL_checkinteger(L, 1);
    gpBody* body = gpSceneGetBody(bodyNum);
    if(!body)
    {
        lua_pushboolean(L, 0);
        return 1;
    }
    bool isOnGround = gpBodyIsOnGround(body);
    lua_pushboolean(L, isOnGround);
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
        {"AddStaticBody", AddStaticBodyToScene},
        {"GetBodyLocation", GetBodyCoordinates},
        {"AddBodyForce", AddForceToBody},
        {"BodyOnGround", IsBodyOnGround},
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