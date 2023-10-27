#include <GoonDash/gnpch.h>
#include <GoonDash/scripting/Draw.h>
// TODO this should not be like this
extern cpSpace *g_Space;

static int CreateBody(lua_State *L)
{
    // Returns the body and the shape
    // shape is the shape (there can be multiple in a body, we just use one) and the body is all the shapes, we use 1:1
    cpBB bbox = cpBBNew(16, 16, 16, 16);
    // cpBB bbox = cpBBNewForExtents(cpv(50,10), 8,8);
    cpFloat mass = 100.0;
    // printf("The infinity is %f\n", INFINITY);
    // cpFloat moment = cpMomentForBox2(INFINITY, bbox);
    cpBody *boxBody = cpSpaceAddBody(g_Space, cpBodyNew(mass, INFINITY));
    cpShape *boxShape = cpSpaceAddShape(g_Space, cpBoxShapeNew2(boxBody, bbox, 0.1));
    cpBodySetPosition(boxBody, cpv(50, 0));
    cpShapeSetFriction(boxShape, 0.4);
    cpShapeSetElasticity(boxShape, 0.0f);
    cpShapeSetCollisionType(boxShape, 1);

    lua_pushlightuserdata(L, boxBody);
    lua_pushlightuserdata(L, boxShape);
    return 2;
}

static int GetBodyPosition(lua_State *L)
{
    // Arg1: body
    // Returns x y of location of body
    if (!lua_islightuserdata(L, 1))
    {
        LogError("You didn't pass in a lua userdata pointer to GetBodyPosition");
        lua_pushnil(L);
        return 0;
    }
    cpBody *body = (cpBody *)lua_touserdata(L, 1);
    if (!body)
    {
        LogError("Bad pointer conversion to chipmunk body passed to lua in GetBodyPosition");
        lua_pushnil(L);
        return 0;
    }
    cpVect pos = cpBodyGetPosition(body);
    lua_pushnumber(L, pos.x);
    lua_pushnumber(L, pos.y);
    return 2;
}

static int AddBodyVelocity(lua_State *L)
{
    // Arg1: body
    // Arg2: x force
    // Arg3: y force
    if (!lua_islightuserdata(L, 1))
    {
        LogError("You didn't pass in a lua userdata pointer to GetBodyPosition");
        lua_pushnil(L);
        return 0;
    }
    cpBody *body = (cpBody *)lua_touserdata(L, 1);
    if (!body)
    {
        LogError("Bad pointer conversion to chipmunk body passed to lua in GetBodyPosition");
        lua_pushnil(L);
        return 0;
    }
    int x = luaL_checknumber(L, 2);
    int y = luaL_checknumber(L, 3);
    cpBodyApplyForceAtLocalPoint(body, cpv(x, y), cpv(0, 0));
    return 0;
}

static int GetBodyVelocity(lua_State *L)
{
    return 0;
}
static int luaopen_GoonPhysics(lua_State *L)
{
    luaL_newmetatable(L, "Lua.Physics");
    luaL_Reg luaPhysicsLib[] = {
        {"CreateBody", CreateBody},
        {"GetBodyPosition", GetBodyPosition},
        {"ApplyForce", AddBodyVelocity},
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