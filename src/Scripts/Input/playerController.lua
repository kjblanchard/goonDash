local PlayerController = {}
local controller = require("Input.controller")

function PlayerController.New()
    local playerController = {}
    playerController.ControllerBindings = {
        [119] = controller.Buttons.Up,
        [115] = controller.Buttons.Down,
        [97] = controller.Buttons.Left,
        [100] = controller.Buttons.Right,
        [32] = controller.Buttons.Confirm,
        [99] = controller.Buttons.Cancel,
    }

end


PlayerController.__index = PlayerController
return PlayerController
