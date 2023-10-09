local SDLKeyMap = {
    [0] = "SDLK_UNKNOWN",
    [13] = "SDLK_RETURN",
    [27] = "SDLK_ESCAPE",
    [8] = "SDLK_BACKSPACE",
    [9] = "SDLK_TAB",
    [32] = "SDLK_SPACE",
    [33] = "SDLK_EXCLAIM",
    [34] = "SDLK_QUOTEDBL",
    [35] = "SDLK_HASH",
    [37] = "SDLK_PERCENT",
    [36] = "SDLK_DOLLAR",
    [38] = "SDLK_AMPERSAND",
    [39] = "SDLK_QUOTE",
    [40] = "SDLK_LEFTPAREN",
    [41] = "SDLK_RIGHTPAREN",
    [42] = "SDLK_ASTERISK",
    [43] = "SDLK_PLUS",
    [44] = "SDLK_COMMA",
    [45] = "SDLK_MINUS",
    [46] = "SDLK_PERIOD",
    [47] = "SDLK_SLASH",
    [48] = "SDLK_0",
    [49] = "SDLK_1",
    [50] = "SDLK_2",
    [51] = "SDLK_3",
    [52] = "SDLK_4",
    [53] = "SDLK_5",
    [54] = "SDLK_6",
    [55] = "SDLK_7",
    [56] = "SDLK_8",
    [57] = "SDLK_9",
    [58] = "SDLK_COLON",
    [59] = "SDLK_SEMICOLON",
    [60] = "SDLK_LESS",
    [61] = "SDLK_EQUALS",
    [62] = "SDLK_GREATER",
    [63] = "SDLK_QUESTION",
    [64] = "SDLK_AT",
    [91] = "SDLK_LEFTBRACKET",
    [92] = "SDLK_BACKSLASH",
    [93] = "SDLK_RIGHTBRACKET",
    [94] = "SDLK_CARET",
    [95] = "SDLK_UNDERSCORE",
    [96] = "SDLK_BACKQUOTE",
    [97] = "SDLK_a",
    [98] = "SDLK_b",
    [99] = "SDLK_c",
    [100] = "SDLK_d",
    [101] = "SDLK_e",
    [102] = "SDLK_f",
    [103] = "SDLK_g",
    [104] = "SDLK_h",
    [105] = "SDLK_i",
    [106] = "SDLK_j",
    [107] = "SDLK_k",
    [108] = "SDLK_l",
    [109] = "SDLK_m",
    [110] = "SDLK_n",
    [111] = "SDLK_o",
    [112] = "SDLK_p",
    [113] = "SDLK_q",
    [114] = "SDLK_r",
    [115] = "SDLK_s",
    [116] = "SDLK_t",
    [117] = "SDLK_u",
    [118] = "SDLK_v",
    [119] = "SDLK_w",
    [120] = "SDLK_x",
    [121] = "SDLK_y",
    [122] = "SDLK_z",
}
local ControllerMap = {
    UP = 1,
    DOWN = 2,
    LEFT = 3,
    RIGHT = 4,
    CONFIRM = 5,
    CANCEL = 6,
}

local ControllerBindings = {
    [119] = ControllerMap.UP,
    [115] = ControllerMap.DOWN,
    [97] = ControllerMap.LEFT,
    [100] = ControllerMap.RIGHT,
    [32] = ControllerMap.CONFIRM,
    [99] = ControllerMap.CANCEL,
}

local KeyboardFunctions = {}
function KeyboardFunctions.SdlToBoundButtons(sdlkey)
    local keybind = ControllerBindings[sdlkey]
    if keybind == nil then return end
    if keybind == 1 then return "UP"
    elseif keybind == 2 then return "Down"
    elseif keybind == 3 then return "Left"
    elseif keybind == 4 then return "Right"
    elseif keybind == 5 then return "Confirm"
    elseif keybind == 6 then return "Cancel"
    end
end

return KeyboardFunctions
