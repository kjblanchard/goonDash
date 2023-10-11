local Controller = {}

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

Controller.ButtonStates = {
    Default = 0,
    Up = 1,
    Down = 2,
    Held = 3,
}

function Controller.New()
    local controller = setmetatable({}, Controller)
    controller.LastFrameButtonsStatus = {
        [Controller.Buttons.Up] = false,
        [Controller.Buttons.Down] = false,
        [Controller.Buttons.Left] = false,
        [Controller.Buttons.Right] = false,
        [Controller.Buttons.Confirm] = false,
        [Controller.Buttons.Cancel] = false,
    }
    controller.ThisFrameButtonStatus = {
        [Controller.Buttons.Up] = false,
        [Controller.Buttons.Down] = false,
        [Controller.Buttons.Left] = false,
        [Controller.Buttons.Right] = false,
        [Controller.Buttons.Confirm] = false,
        [Controller.Buttons.Cancel] = false,
    }
    controller.KeyUpBindFunctions = {
        [Controller.Buttons.Up] = {},
        [Controller.Buttons.Down] = {},
        [Controller.Buttons.Left] = {},
        [Controller.Buttons.Right] = {},
        [Controller.Buttons.Confirm] = {},
        [Controller.Buttons.Cancel] = {},
    }
    controller.KeyDownBindFunctions = {
        [Controller.Buttons.Up] = {},
        [Controller.Buttons.Down] = {},
        [Controller.Buttons.Left] = {},
        [Controller.Buttons.Right] = {},
        [Controller.Buttons.Confirm] = {},
        [Controller.Buttons.Cancel] = {},
    }
    controller.KeyHeldBindFunctions = {
        [Controller.Buttons.Up] = {},
        [Controller.Buttons.Down] = {},
        [Controller.Buttons.Left] = {},
        [Controller.Buttons.Right] = {},
        [Controller.Buttons.Confirm] = {},
        [Controller.Buttons.Cancel] = {},
    }
    return controller
end

function Controller:UpdateButtonStatus(button, state)
    if self.ThisFrameButtonStatus[button] == nil then return end
    self.ThisFrameButtonStatus[button] = state
end

function Controller:Update()
    for i = 1, Controller.Buttons.Max do
        if not self.LastFrameButtonsStatus[i] and self.ThisFrameButtonStatus[i] then
            for j = 1, #self.KeyDownBindFunctions do
                if self.KeyDownBindFunctions[i][j] then self.KeyDownBindFunctions[i][j]() end
            end
        elseif self.LastFrameButtonsStatus[i] and not self.ThisFrameButtonStatus[i] then
            for j = 1, #self.KeyUpBindFunctions do
                if self.KeyUpBindFunctions[i][j] then self.KeyUpBindFunctions[i][j]() end
            end
        elseif self.LastFrameButtonsStatus[i] and self.ThisFrameButtonStatus[i] then
            for j = 1, #self.KeyHeldBindFunctions do
                if self.KeyHeldBindFunctions[i][j] then self.KeyHeldBindFunctions[i][j]() end
            end
        end
        self.LastFrameButtonsStatus[i] = self.ThisFrameButtonStatus[i]
    end
end

function Controller:BindFunction(button, buttonState, func)
    if buttonState == 1 then
        table.insert(self.KeyUpBindFunctions[button], func)
    elseif buttonState == 2 then
        table.insert(self.KeyDownBindFunctions[button], func)
    elseif buttonState == 3 then
        table.insert(self.KeyHeldBindFunctions[button], func)
    end
end

function Controller:UnbindFunction(button, buttonState, func)
    if button == 1 then
        for i = 1, #self.KeyUpBindFunctions do
            if self.KeyUpBindFunctions[i] == func then table.remove(self.KeyUpBindFunctions[i]) end
        end
    elseif button == 2 then
        for i = 1, #self.KeyDownBindFunctions do
            if self.KeyDownBindFunctions[i] == func then table.remove(self.KeyDownBindFunctions[i]) end
        end
    elseif button == 3 then
        for i = 1, #self.KeyHeldBindFunctions do
            if self.KeyHeldBindFunctions[i] == func then table.remove(self.KeyHeldBindFunctions[i]) end
        end
    end
end

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
