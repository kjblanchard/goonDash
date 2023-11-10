#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/Physics.h>
#include <GoonDash/scripting/SdlRect.h>
#include <GoonPhysics/GoonPhysics.h>
#include <GoonPhysics/aabb.h>

static int AddBodyToScene(lua_State *L)
{
    // Arg1: SdlRect For Body
    // Arg2: int type of body
    // Return1: Body integer for lookup.
    SDL_Rect bodySdlRect = GetRectFromLuaTable(L, 1);
    int bodyType = luaL_checkinteger(L, 2);
    gpBB bb = gpBBNew(bodySdlRect.x, bodySdlRect.y, bodySdlRect.w, bodySdlRect.h);
    gpBody *body = gpBodyNew(bb);
    int bodyNum = gpSceneAddBody(body);
    printf("Body just added to scene is %d", bodyNum);
    body->bodyType = bodyType;
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
    body->bodyType = 0;
    int bodyNum = gpSceneAddStaticBody(body);
    lua_pushinteger(L, bodyNum);
    return 1;
}

// Used to not have to push nil to lua?
static gpBody *GetBodyFromScene(lua_State *L, int bodyNum)
{
    gpBody *body = gpSceneGetBody(bodyNum);
    if (!body)
    {
        lua_pushnil(L);
    }
    return body;
}

static int GetOverlappingBodies(lua_State *L)
{
    // Arg1 Body Num
    // Arg2 Body Type
    // Return1 Table of Overlapping body nums of specific type
    int bodyNum = luaL_checkinteger(L, 1);
    int bodyType = luaL_checkinteger(L, 2);
    gpBody *body = GetBodyFromScene(L, bodyNum);
    if (!body)
        return 1;
    lua_newtable(L);
    int tableListLoc = lua_gettop(L);
    int bodiesAdded = 0;
    for (size_t i = 0; i < body->numOverlappingBodies; i++)
    {
        gpBody *overlapBody = body->overlappingBodies[i];
        if (overlapBody->bodyType != bodyType)
            continue;
        lua_pushnumber(L, overlapBody->bodyNum);
        lua_rawseti(L, tableListLoc, ++bodiesAdded);
    }
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
    gpBody *body = gpSceneGetBody(bodyNum);
    if (!body)
    {
        return 0;
    }
    body->velocity.x += forceX;
    body->velocity.y += forceY;
    return 0;
}

static int ToggleBodyGravity(lua_State *L)
{
    // Arg1: Body num
    // Arg2: Gravity Boolean
    int bodyNum = luaL_checkinteger(L, 1);
    if (!lua_isboolean(L, 2))
    {
        LogWarn("Bad param passed into gravity toggle");
    }
    int gravity = lua_toboolean(L, 2);
    gpBody *body = GetBodyFromScene(L, bodyNum);
    if (!body)
        return 1;
    body->gravityEnabled = gravity;
    lua_pushboolean(L, 1);
}

static int SetBodyType(lua_State *L)
{
    // Arg1: Body num
    // Arg2: BodyType Int
    int bodyNum = luaL_checkinteger(L, 1);
    int bodyType = luaL_checkinteger(L, 2);
    gpBody *body = GetBodyFromScene(L, bodyNum);
    if (!body)
        return 1;
    body->bodyType = bodyType;
    lua_pushboolean(L, 1);
}

static int IsBodyOnGround(lua_State *L)
{
    // Arg1: Body num
    // Return1: is on ground bool
    int bodyNum = luaL_checkinteger(L, 1);
    gpBody *body = gpSceneGetBody(bodyNum);
    if (!body)
    {
        lua_pushboolean(L, 0);
        return 1;
    }
    bool isOnGround = gpBodyIsOnGround(body);
    lua_pushboolean(L, isOnGround);
    return 1;
}

static int GetOverlapDirection(lua_State *L)
{
    // Arg1: Body num
    // Arg1: Body num
    int bodyNum = luaL_checkinteger(L, 1);
    int overlapBodyNum = luaL_checkinteger(L, 2);
    gpBody *body = gpSceneGetBody(bodyNum);
    gpBody *overlapBody = gpSceneGetBody(overlapBodyNum);
    if (!body || !overlapBody)
    {
        lua_pushboolean(L, 0);
        return 1;
    }
    int overlapDirection = gpGetOverlapDirection(&body->boundingBox, &overlapBody->boundingBox);
    lua_pushinteger(L, overlapDirection);
    return 1;
}

static int GetBodyCoordinates(lua_State *L)
{
    // Arg1: Body num
    // Return1: x
    // Return2: y
    int bodyRef = luaL_checkinteger(L, 1);
    gpBody *body = gpSceneGetBody(bodyRef);
    if (!body)
    {
        LogWarn("Could not get body num %d from the physics scene", bodyRef);
        lua_pushnil(L);
        return 1;
    }
    lua_pushnumber(L, body->boundingBox.x);
    lua_pushnumber(L, body->boundingBox.y);
    return 2;
}

static int GetBodyVelocity(lua_State *L)
{
    // Arg1: Body num
    // Return1: x
    // Return2: y
    int bodyRef = luaL_checkinteger(L, 1);
    gpBody *body = gpSceneGetBody(bodyRef);
    if (!body)
    {
        LogWarn("Could not get body num %d from the physics scene", bodyRef);
        lua_pushnil(L);
        return 1;
    }
    lua_pushnumber(L, body->velocity.x);
    lua_pushnumber(L, body->velocity.y);
    return 2;
}

static int SetBodyVelocity(lua_State *L)
{
    // Arg1: Body num
    // Arg2: velocity x
    // Arg3: velocity y
    int bodyRef = luaL_checkinteger(L, 1);
    gpBody *body = gpSceneGetBody(bodyRef);
    if (!body)
    {
        LogWarn("Could not get body num %d from the physics scene", bodyRef);
        lua_pushnil(L);
        return 1;
    }
    float velX = luaL_checknumber(L, 2);
    float velY = luaL_checknumber(L, 3);
    body->velocity.x = velX;
    body->velocity.y = velY;
    return 0;
}

static int luaopen_GoonPhysics(lua_State *L)
{
    luaL_newmetatable(L, "Lua.Physics");
    luaL_Reg luaPhysicsLib[] = {
        {"AddBody", AddBodyToScene},
        {"AddStaticBody", AddStaticBodyToScene},
        {"GetBodyLocation", GetBodyCoordinates},
        {"GetBodyVelocity", GetBodyVelocity},
        {"AddBodyForce", AddForceToBody},
        {"SetBodyType", SetBodyType},
        {"SetBodyGravity", ToggleBodyGravity},
        {"BodyOnGround", IsBodyOnGround},
        {"GetOverlappingBodies", GetOverlappingBodies},
        {"GetOverlapDirection", GetOverlapDirection},
        {"SetBodyVelocity", SetBodyVelocity},
        {NULL, NULL} // Sentinel value to indicate the end of the table
    };
    luaL_newlib(L, luaPhysicsLib);
    return true;
}

int RegisterPhysicsFunctions(lua_State *L)
{
    luaL_requiref(L, "GoonPhysics", luaopen_GoonPhysics, 0);
}