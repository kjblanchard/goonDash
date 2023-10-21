---Controller class, used by Player controllers and by ai controllers
local Controller = {}
-- Total amount of players, currently only 1 supported
Controller.PlayerControllers = {}
-- All the buttons on a controller in this game
Controller.Buttons = {
    Default = 0,
    Up = 1,
    Down = 2,
    Left = 3,
    Right = 4,
    Confirm = 5,
    Cancel = 6,
    Max = 7
}
---The different button states, downorheld is used only for binding
Controller.ButtonStates = {
    Default = 0,
    Up = 1,
    Down = 2,
    Held = 3,
    DownOrHeld = 4,
}

function Controller.New()
    local controller = setmetatable({}, Controller)
    controller.LastFrameButtonsStatus = {}
    controller.ThisFrameButtonStatus = {}
    for i = 1, Controller.Buttons.Max do
        controller.LastFrameButtonsStatus[i] = false
        controller.ThisFrameButtonStatus[i] = false
    end
    controller.KeyBindFunctions = {}
    return controller
end

function Controller:UpdateButtonStatus(button, state)
    self.ThisFrameButtonStatus[button] = state
end

function Controller:Update()
    for i = 1, Controller.Buttons.Max do
        if not self.LastFrameButtonsStatus[i] and self.ThisFrameButtonStatus[i] and
            self.KeyBindFunctions[i][Controller.ButtonStates.Down] then
            for j = 1, #self.KeyBindFunctions[i][Controller.ButtonStates.Down] do
                if self.KeyBindFunctions[i][Controller.ButtonStates.Down][j] then self.KeyBindFunctions[i][
                        Controller.ButtonStates.Down][j]()
                end
            end
        elseif self.LastFrameButtonsStatus[i] and not self.ThisFrameButtonStatus[i] and
            self.KeyBindFunctions[i][Controller.ButtonStates.Up] then
            for j = 1, #self.KeyBindFunctions[i][Controller.ButtonStates.Up] do
                if self.KeyBindFunctions[i][Controller.ButtonStates.Up][j] then self.KeyBindFunctions[i][
                        Controller.ButtonStates.Up][j]()
                end
            end
        elseif self.LastFrameButtonsStatus[i] and self.ThisFrameButtonStatus[i] and
            self.KeyBindFunctions[i][Controller.ButtonStates.Held] then
            for j = 1, #self.KeyBindFunctions[i][Controller.ButtonStates.Held] do
                if self.KeyBindFunctions[i][Controller.ButtonStates.Held][j] then self.KeyBindFunctions[i][
                        Controller.ButtonStates.Held][j]()
                end
            end
        end
        self.LastFrameButtonsStatus[i] = self.ThisFrameButtonStatus[i]
    end
end

function Controller:BindFunction(button, buttonState, func)
    self.KeyBindFunctions[button] = self.KeyBindFunctions[button] or {}
    if buttonState == Controller.ButtonStates.DownOrHeld then
        self.KeyBindFunctions[button][Controller.ButtonStates.Down] = self.KeyBindFunctions[button][
            Controller.ButtonStates.Down] or {}
        self.KeyBindFunctions[button][Controller.ButtonStates.Held] = self.KeyBindFunctions[button][
            Controller.ButtonStates.Held] or {}
        table.insert(self.KeyBindFunctions[button][Controller.ButtonStates.Down], func)
        table.insert(self.KeyBindFunctions[button][Controller.ButtonStates.Held], func)
    else
        self.KeyBindFunctions[button][buttonState] = self.KeyBindFunctions[button][buttonState] or {}
        table.insert(self.KeyBindFunctions[button][buttonState], func)
    end
end

-- Function that handles all sdl events this frame so that we can update properly at end of frame
function Controller.OnInput(sdlkey, isKeyDown)
    for i = 1, #Controller.PlayerControllers do
        Controller.PlayerControllers[i]:HandleButtonEvent(sdlkey, isKeyDown)
    end
end

-- Temporary function that updates all controllers
function Controller.UpdateControllers()
    for i = 1, #Controller.PlayerControllers do
        Controller.PlayerControllers[i]:Update()
    end
end

Controller.__index = Controller
return Controller
