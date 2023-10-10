local Controller = {}

-- All the buttons on a controller in this game
Controller.Buttons = {
    Default = 0,
    Up = 1,
    Down = 2,
    Left = 3,
    Right = 4,
    Confirm = 5,
    Cancel = 6,
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
        [Controller.Buttons.Up] = nil,
        [Controller.Buttons.Down] = nil,
        [Controller.Buttons.Left] = nil,
        [Controller.Buttons.Right] = nil,
        [Controller.Buttons.Confirm] = nil,
        [Controller.Buttons.Cancel] = nil,
    }
    controller.KeyDownBindFunctions = {
        [Controller.Buttons.Up] = nil,
        [Controller.Buttons.Down] = nil,
        [Controller.Buttons.Left] = nil,
        [Controller.Buttons.Right] = nil,
        [Controller.Buttons.Confirm] = nil,
        [Controller.Buttons.Cancel] = nil,
    }
    controller.KeyHeldBindFunctions = {
        [Controller.Buttons.Up] = nil,
        [Controller.Buttons.Down] = nil,
        [Controller.Buttons.Left] = nil,
        [Controller.Buttons.Right] = nil,
        [Controller.Buttons.Confirm] = nil,
        [Controller.Buttons.Cancel] = nil,
    }
    return controller
end

function Controller:UpdateButtonStatus(button, state)
    if self.ThisFrameButtonStatus[button] == nil then return end
    self.ThisFrameButtonStatus[button] = state
end

function Controller:Update()
    for i = 1, #Controller.Buttons do
        if not self.LastFrameButtonsStatus[i] and self.ThisFrameButtonStatus[i] then
            for j = 1, #self.KeyDownBindFunctions do
                if self.KeyDownBindFunctions[j] then self.KeyDownBindFunctions[j]() end
            end
        elseif self.LastFrameButtonsStatus[i] and not self.ThisFrameButtonStatus[i] then
            for j = 1, #self.KeyUpBindFunctions do
                if self.KeyUpBindFunctions[j] then self.KeyUpBindFunctions[j]() end
            end
        elseif self.LastFrameButtonsStatus[i] and self.ThisFrameButtonStatus[i] then
            for j = 1, #self.KeyHeldBindFunctions do
                if self.KeyHeldBindFunctions[j] then self.KeyHeldBindFunctions[j]() end
            end
        end
        self.LastFrameButtonsStatus[i] = self.ThisFrameButtonStatus[i]
    end
end

function Controller:BindFunction(button, buttonState, func)
    if button == 1 then
        table.insert(self.KeyUpBindFunctions)
    elseif button == 2 then
        table.insert(self.KeyDownBindFunctions)
    elseif button == 3 then
        table.insert(self.KeyHeldBindFunctions)
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

Controller.__index = Controller
return Controller
