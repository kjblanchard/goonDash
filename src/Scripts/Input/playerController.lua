local PlayerController = {}
local controller = require("Input.controller")

local anonymousFunction = function()
    print("Confirm button was pressed from the bindings!!")
end

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
    playerController.controller:BindFunction(controller.Buttons.Confirm, controller.ButtonStates.Down,  anonymousFunction)
    playerController.controller:BindFunction(controller.Buttons.Up, controller.ButtonStates.Held, function ()
        print("Hello world UPHELD")
    end)
    -- Add to list of Player controllers
    table.insert(controller.PlayerControllers, playerController)
    print("Thing made")
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
