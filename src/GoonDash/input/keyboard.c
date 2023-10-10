#include <GoonDash/gnpch.h>
#include <GoonDash/input/keyboard.h>

int HandleKeyboardEvent(SDL_Event *event, lua_State *L)
{
    // Handle quit events currently
    if (event->type == SDL_KEYDOWN && (event->key.keysym.sym == SDLK_q || event->key.keysym.sym == SDLK_ESCAPE))
    {
        SDL_Event quit;
        quit.type = SDL_QUIT;
        SDL_PushEvent(&quit);
        return true;
    }

    // Don't pass repeat keys to lua, as he handles the processing
    if(event->key.repeat)
    {
        return true;
    }

    lua_getglobal(L, "Lua");
    lua_getfield(L, -1, "InputEvent");
    // Place 2 things on the stack.
    int symbol = event->key.keysym.sym;
    bool keydown = event->type == SDL_KEYDOWN ? true : false;
    lua_pushinteger(L, symbol);
    lua_pushboolean(L, keydown);
    int result = lua_pcall(L, 2, 0, 0);
    if (result != LUA_OK)
    {
        const char *error = lua_tostring(L, -1);
        LogError("Failed script, %s, error result: %d, error: %s", "InputEvent", result, error);
        lua_pop(L, 1);
        return false;
    }
    lua_settop(L, 0);
    return true;
    // Push the event to lua?
}