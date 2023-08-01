Lua = {}

function Lua.Initialize()
    require("settings")
    InitializeWindow(Settings.windowName, Settings.windowWidth, Settings.windowHeight)
end

function Lua.Start()
    print("Hello from Lua Start!")
    DoIt()

end

function Lua.Update()
    print("Hello from Lua Update!")

end

function Lua.Draw()
    print("Hello from Lua Draw!")

end
