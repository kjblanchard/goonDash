local PlayerController = {}
local controller = require("Input.controller")

function PlayerController.New()
    local playerController = setmetatable({}, PlayerController)
    -- Set default bindings
    playerController.ControllerBindings = {
        [119] = controller.Buttons.Up,
        [115] = controller.Buttons.Down,
        [97] = controller.Buttons.Left,
        [100] = controller.Buttons.Right,
        [32] = controller.Buttons.Confirm,
        [99] = controller.Buttons.Cancel,
    }

    playerController.controller = controller.New()
    -- Add to list of Player controllers
    table.insert(controller.PlayerControllers, playerController)
    return playerController
end

function PlayerController:HandleButtonEvent(sdlkey, isKeyDown)
    -- Check to see if the button is mapped to a controller button
    local keybind = self.ControllerBindings[sdlkey]
    if keybind == nil then return end

    -- Tell the controller this button state.
    self.controller:UpdateButtonStatus(keybind, isKeyDown)
end

function PlayerController:Update()
    self.controller:Update()
end

PlayerController.__index = PlayerController
return PlayerController
